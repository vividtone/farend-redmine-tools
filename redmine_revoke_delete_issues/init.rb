require 'redmine'
require_dependency 'revoke_delete_issues_patch'

Redmine::Plugin.register :redmine_revoke_delete_issues do
  name 'Redmine Revoke Delete Issues plugin'
  author 'FAR END Technologies Corporation'
  description 'Revoke :delete_issues permission from all users including admin. This plugin can be run on production mode only.'
  version '20091122'
end
