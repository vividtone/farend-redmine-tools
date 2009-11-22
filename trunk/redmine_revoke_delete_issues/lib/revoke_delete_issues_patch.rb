require_dependency 'role'
require_dependency 'user'

module RevokeDeleteIssuesRolePatch
  def self.included(base)
    base.send(:include, WrapperMethods)

    base.class_eval do
      alias_method_chain :permissions, :revoke
      unloadable
    end
  end

  module WrapperMethods
    # ユーザーの権限が参照されたときに権限の一覧から:delete_issues権限を削除
    def permissions_with_revoke
      permissions_without_revoke - [:delete_issues]
    end
  end
end

module RevokeDeleteIssuesUserPatch
  def self.included(base)
    base.send(:include, WrapperMethods)

    base.class_eval do
      alias_method_chain :allowed_to?, :revoke
      unloadable
    end
  end

  module WrapperMethods
    # チケット削除可否の問い合わせには常にfalseを返す。
    # 元のUser::allowed_to?では管理者ユーザーには無条件に全ての操作が許可され
    # ているため、Role::permissionsから:delete_issues権限を除いただけでは管理
    # 者ユーザーに対してチケット削除を禁止することができない。
    def allowed_to_with_revoke?(action, project, options={})
      return false if action == :delete_issues
      return false if action.respond_to?("[]") &&
          action[:controller] == 'issues' && action[:action] == 'destroy'
      allowed_to_without_revoke?(action, project, options)
    end
  end
end

Role.send(:include, RevokeDeleteIssuesRolePatch)
User.send(:include, RevokeDeleteIssuesUserPatch)
