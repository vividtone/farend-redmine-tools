#!/usr/bin/env ruby
#
# Munin plugin for Redmine
#
# Copyright (C) 2009 FAR END Technologies Corporation
# Licensed under the MIT license.
#
# Changelog: 
# 2009/02/11 first release

#--------------------------------------------------------------------------
# Change the following values according to your Redmine setup.

# database.yml path
REDMINE_DATABASE_YML = '/some/where/config/database.yml'

# RAILS_ENV environment
REDMINE_ENV = 'production'

# Project identifier
REDMINE_PROJECT = 'demo'
#--------------------------------------------------------------------------

require 'rubygems'
require 'mysql'
require 'yaml'

SQL_QUERY_ISSUES_CLOSED = <<END
select count(*) from issues, issue_statuses, projects
where issues.status_id = issue_statuses.id
and issues.project_id = projects.id
and projects.identifier = ?
and issue_statuses.is_closed <> 0
END

SQL_QUERY_ISSUES_TOTAL = <<END
select count(*) from issues, projects
where issues.project_id = projects.id
and projects.identifier = ?
END

MUNIN_CONFIG_TEXT = <<END
graph_title Redmine Issues (#{REDMINE_PROJECT})
graph_vlabel count
total.label total issues
closed.label closed issues
END


if ARGV[0] == 'config' then
  puts MUNIN_CONFIG_TEXT
  exit
end

dbconf = YAML.load_file(REDMINE_DATABASE_YML)
host = dbconf[REDMINE_ENV]['host']
username = dbconf[REDMINE_ENV]['username']
password = dbconf[REDMINE_ENV]['password']
database = dbconf[REDMINE_ENV]['database']

db = Mysql::new(host, username, password, database)
(closed_issues, total_issues) = 
  [SQL_QUERY_ISSUES_CLOSED, SQL_QUERY_ISSUES_TOTAL].map do |sql|
    st = db.prepare(sql)
    st.execute(REDMINE_PROJECT)
    st.fetch[0].to_i
  end
db.close

puts "total.value #{total_issues}"
puts "closed.value #{closed_issues}"
