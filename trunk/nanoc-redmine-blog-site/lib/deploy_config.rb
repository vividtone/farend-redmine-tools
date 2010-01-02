@site[:deploy] = {
  :default => {
    :dst =>     "root@venus.farend.jp:/mnt/user0000/html-redmine-blog",
    :options => [ '-gpPrvz', '--exclude=".svn"', '--delete-after'],
  }
}
