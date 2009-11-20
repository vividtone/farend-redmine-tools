require 'redmine'
require_dependency 'application_helper_patch'

Redmine::Plugin.register :redmine_application_helper_patch do
  name 'Redmine Application Helper Patch plugin(for TestLink)'
  author 'FAR END Technologies Co,.Ltd.'
  description 'This is a plugin for collaboration to TestLink'
  version '0.0.1'
end
