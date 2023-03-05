# Some informtation about ansible

### Системы:
 - pull <- chef, puppet, saltstack
 - push <- ansible


## Команды:
 - ansible --version


## Example-1

### hosts.txt (inventory):
```
10.50.1.1
webserver.google.com
myserver ansible_host=10.20.30.40

[staging_servers]
linuxX ansible_host=172.31.8.69 ansible_user=ec2-user (ansible_pass=1234 OR ansible_ssh_private_key_file=<path to private key>)

[prod_servers]
linux1 ansible_host=172.31.27.15 ansible_user=ec2-user ansible_ssh_private_key_file=<path1 to private key>
linux2 ansible_host=172.31.27.118 ansible_user=ec2-user ansible_ssh_private_key_file=<path2 to private key>

[windows_servers]
windows2012     ansible_hosts=172.31.4.99
windows2016     ansible_hosts=172.31.4.170

[windows_servers:vars]
ansible_user = myadmin
(ansible_password = 12345678)
ansible_port = 5986
ansible_connection = winrm
ansible_winrm_secret_cert_validation = ignore

[staging_DB]
192.168.1.1
192.168.1.2

[staging_WEB]
192.168.2.1
192.168.2.2

[staging_APP]
192.168.3.1
192.168.3.2

[staging_ALL:children]
staging_DB
staging_WEB
staging_APP


[prod_DB]
192.100.1.1
192.100.1.2

[prod_WEB]
192.100.2.1
192.100.2.2

[prod_APP]
192.100.3.1
192.100.3.2

[prod_ALL:children]
prod_DB
prod_WEB
prod_APP


[DB_ALL:children]
staging_DB
prod_DB


[different:children]
DN_ALL
prod_ALL

[different:vars]
message=Hello
```


 - ansible -i hosts.txt all -m ping  
-i hosts.txt    = указать инвентори  
all             = группа хостов (например prod_servers)  
-m ping         = указать запускаемый модуль  



### ansible.cfg
```
[defaults]
host_key_checking   = false
inventory           = ./hosts.txt
```


 - ansible all -m ping
 - ansible-inventory --list  
просмотреть какие переменные в инвентори и описание серверов
 - ansible-inventory --graph  
просмотреть какие переменные в инвентори и описание серверов





## Example-2

### ansible.cfg
```
[defaults]
host_key_checking   = false
inventory           = ./hosts.txt
```
### hosts.txt (inventory):
```
[staging_servers]
linuxX ansible_host=172.31.8.69 ansible_user=ec2-user ansible_ssh_private_key_file=<path to private key>

[prod_servers]
linux1 ansible_host=172.31.27.15 
linux2 ansible_host=172.31.27.118

[prod_servers:vars]
ansible_user=ec2-user
ansible_user=ec2-user ansible_ssh_private_key_file=<path to private key>
```

 - ansible all -m ping
 - ansible staging_servers -m setup   
посмотреть всю информацию о серверах (айпи, операционка, архитектрура, время, сетевые карты, dns-name, kernel-version). Все эти переменные можно использовать
 - amsible all -m shell -a "uptime > a.txt && pipi sinstall tree && echo pep >> bruh.txt"  
выполнить шелл команду
 - ansible all -m command -a "...."  
аналогично шелл, но с ограничениями (не работают пайпы и тд)


### hello.txt
```
Privet
```
 - ansible all m copy -a "arc=privet.txt dest=/home mode=777" -b  
скопировать файл на сервера
 - ansible prod_servers -m file -a "path=/home/privet.txt state=absent" -b  
создать/удалить файлы и директории
 - ansible all -m get_url -a "url=https://aaaaaa.com/bbb dest=/home" -b  
скачать из интернета
 - ansible all -m yum -a "name=state=stress state=installed" -b
установить/удалить stress на сервера
 - ansible all -m uri -a "url=http://www.advt.it.net return_content=yes"
прочитать страничку из интернета
 - ansible all -m yum -a "name=httpd state=latest" -b
 - ansible all -m yum -a "name=httpd state=removed" -b
установить апаче
 - ansible all -m service -a "name=httpd state=started enables=yes" -b
запустить сервис и чтобы при перезагрузке запускался
 - ansible all m copy -a "arc=privet.txt dest=/home mode=777" -b -vvvv
для дебагинга можно написать -v
 - ansible-doc -l
посмотреть все модули




## Example-3


### directories structure
```
.
├── ansible.cfg
├── group_vars
│   ├── ALL_SERVERS_DB
│   ├── PROD_SERVERS_WEB
│   └── STAGING_SERVERS_WEB
└── hosts.txt
```


### hosts.txt
```
[STAGING_SERVERS_WEB]
linuxX1 ansible_host=172.31.8.69
linuxX1 ansible_host=172.31.8.69 password=mysecret


[PROD_SERVERS_WEB]
linuxX1 ansible_host=172.31.8.16
linuxX1 ansible_host=172.31.8.168



[STAGING_SERVERS_DB]
192.168.2.1
192.168.2.2

[PROD_SERVERS_DB]
192.168.2.1
192.168.2.2

[ALL_SERVERS_DB:children]
STAGING_SERVERS_DB
PROD_SERVERS_DB
```
### STAGING_SERVERS_WEB
```
---
ansible_user                 : ec2-user
ansible_ssh_private_key_file : <path to file>
```
### PROD_SERVERS_WEB
```
---
ansible_user                 : ec2-user
ansible_ssh_private_key_file : <path to file>
```
### ALL_SERVERS_DB
```
---
db_endpoint : xxxxxx.yyyyyyy.com:4151
owner       : vasya
location    : "Huston, TX"
```