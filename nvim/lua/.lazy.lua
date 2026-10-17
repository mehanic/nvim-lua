-- .lazy.lua у корені проєкту
vim.g.dbs = {
  dev_postgres = "postgres://user:password@localhost:5432/mydb",
  staging_mysql = "mysql://root:password@192.168.1.10:3306/appdb",
}
return {}
