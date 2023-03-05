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
 - ansible all m copy -a "src=privet.txt dest=/home mode=777" -b  
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
 - ansible all m copy -a "src=privet.txt dest=/home mode=777" -b -vvvv
для дебагинга можно написать -v
 - ansible-doc -l
посмотреть все модули




## Example-3


### Structure of directories
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



## Example-4 (Playbooks)

### Structure of directories
```
.
├── ansible.cfg
├── group_vars
│   └── PROD_SERVERS_WEB
└── hosts.txt
├── MyWebSite
│   └── index.html
├── playbook1.yml
├── playbook2.yml
└── playbook3.yml
```

### playbook1.yml
```
---
- name: Test Connection to my servers
  hosts: all
  become: yes

  tasks:
  - name: Ping me servers
    ping:
```
 - ansible-playbook playbook1.yml



### playbook2.yml
```
---
- name: Install default Apache Web Server
  hosts: all
  become: yes

  tasks:
  - name: Install Apache WebServer
    yum: name=httpd state=latest
  - name: Start Apache and enable it on the every boot
    service: name=httpd state=started enabled=yes
```
- ansible-playbook playbook2.yml



### playbook3.yml
```
---
- name: Install Apache and upload my Web page
  hosts: all
  become: yes

  vars:
    source_file: ./MyWebSite/index.html
    destin_file: /var/www/html

  tasks:
  - name: Install Apache WebServer
    yum: name=httpd state=latest

  - name: copy my HomePage to servers
    copy: src={{ source_file }} dest = {{ destin_file }} mode=0555
    notify: Restart Apache

  - name: Start Apache and enable it on the every boot
    service: name=httpd state=started enabled=yes


  handlers:
  - name: Restart Apache
    service: name=httpd state=restarted
```
- ansible-playbook playbook3.yml



## Example-5 (debug, setfactor, register)

### Structure of directories
```
.
├── ansible.cfg
├── group_vars
│   └── PROD_SERVERS_WEB
└── hosts.txt
└── playbook.yml
```

### hosts.txt
```
[PROD_SERVERS_WEB]
linux1 ansible_host=172.31.27.113       owner=Vasya
linux2 ansible_host=172.31.27.129       owner=Petya
linux3 ansible_host=172.31.27.65       owner=Nikolay
```

### playbook.yml
```
---
- name: My super puper Playbook for variables lesson
  hosts: all
  become: yes

  vars:
    message1: Privet
    message2: World
    secret: DJFVBJKDFVBJSDLKANDVLK;ANFVJK

  tasks:
  - name: Print secret variables
    debug:
      var: secret

  - debug:
      msg: "secret word: {{ secret }}"

  - debug:
      msg: "this server owner is -->{{ owner }}<--"

  - set_fact: full_message="{{ Privet }} {{ World }} from {{owner}}"

  - debug:
      var: full_message

  - debug:
      var: ansible_distribution

  - shell: uptime
    register: results  # сохранить вывод output в переменную results

  - debug:
      var: results

  - debug:
      var: results.stdout
```
- ansible-playbook playbook.yml
- ansible all -m setup


## Example-6 (Block-When)

### Structure of directories
```
.
├── ansible.cfg
├── group_vars
│   └── ALL_LINUX
└── hosts.txt
├── MyWebSite
│   └── index.html
└── playbook.yml
```

### hosts.txt
```
[ALL_LINUX]
linux1 ansible_host=172.31.27.113
linux2 ansible_host=172.31.27.129
linux3 ansible_host=172.31.27.65
```

### playbook.yml
```
---
- name: Install Apache and upload my Web page
  hosts: all
  become: yes

  vars:
    source_file: ./MyWebSite/index.html
    destin_file: /var/www/html

  tasks:
  - name: Check and Print LINUX Version
    debug: var=ansible_os_family

  - block: # ====== block for RedHat ==========

      - name: Install Apache WebServer for RedHat
        yum: name=httpd state=latest                     # <-------------

      - name: copy my HomePage to servers
        copy: src={{ source_file }} dest = {{ destin_file }} mode=0555
        notify: Restart Apache RedHat

      - name: Start Apache and enable it on the every boot for RedHat
        service: name=httpd state=started enabled=yes    # <-------------
        
    when: ansible_os_family == "RedHat"

  - block: # ====== block for ubuntu ===========

      - name: Install Apache WebServer for Debian
        apt: name=apache2 state=latest                   # <-------------

      - name: copy my HomePage to servers
        copy: src={{ source_file }} dest = {{ destin_file }} mode=0555
        notify: Restart Apache Debian

      - name: Start Apache and enable it on the every boot for Debian
        service: name=apache2 state=started enabled=yes  # <-------------
        
    when: ansible_os_family != "RedHat"

  handlers:
  - name: Restart Apache RedHat
    service: name=httpd state=restarted
  - name: Restart Apache Debian
    service: name=apache2 state=restarted
```
- ansible-playbook playbook.yml
- ansible all -m setup



## Example-7 (Loop, with_items, until, with_fileglob; templates)

### Structure of directories
```
.
├── ansible.cfg
├── group_vars
│   └── ALL_LINUX
└── hosts.txt
├── MyWebSite
│   └── index.html
├── MyWebSite2
│   ├── bahamas.png
│   ├── bulgaria.png
│   ├── jordan.png
│   ├── newzeland.png
│   └── index.j2
├── loop.yml
└── playbook.yml
```

### hosts.txt
```
[PROD_SERVERS_WEB]
linux1 ansible_host=172.31.27.113       owner=Vasya
linux3 ansible_host=172.31.27.65        owner=Petya
```

### index.j2
```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<body>
    Owner of this server is {{ owner }}.
    Server hostname : {{ ansible_hostname }}.
    Server OS Family : {{ ansible_os_family }}.
    Ip Adress : {{ ansible_default_ipv4.address }}
</body>
</html>
```


### loop.yml
```
---
- name: Loops Playbook
  hosts:linux3
  become: yes

  tasks:
  - name: Say hello to ALL
    debug: msg="Hello {{ item }}"
    with_items: # or loop
        - "Vasya"
        - "Petya"
        - "Masha"
        - "Olya"

  - name: Loop Until example
    shell: echo -n Q >> myfile.txt && cat myfile.txt
    register: output
    delay: 2 # in seconds
    retries: 10
    until: output.stdout.find("QQQQ") == false

  - name: Print final output
    debug:
      var: output.stdout

  - name: Install many packages
    yum: name={{ item }} state=installed
    with_items:
        - python
        - tree
        -mysql-client
```
- ansible-playbook loop.yml


### playbook.yml
```
---
- name: Install Apache and upload my Web page
  hosts: all
  become: yes

  vars:
    source_folder: ./MyWebSite2
    destin_folder: /var/www/html

  tasks:
  - name: Check and Print LINUX Version
    debug: var=ansible_os_family

  - block: # ====== block for RedHat ==========

      - name: Install Apache WebServer for RedHat
        yum: name=httpd state=latest                     # <-------------

      - name: Start Apache and enable it on the every boot for RedHat
        service: name=httpd state=started enabled=yes    # <-------------
        
    when: ansible_os_family == "RedHat"

  - block: # ====== block for ubuntu ===========

      - name: Install Apache WebServer for Debian
        apt: name=apache2 state=latest                   # <-------------

      - name: Start Apache and enable it on the every boot for Debian
        service: name=apache2 state=started enabled=yes  # <-------------
        
    when: ansible_os_family != "RedHat"


  - name: Generate index.html file
    template: src={{ source_folder }}/index.j2 dest={{ destin_folder }}/index.html mode=0555
    notify: 
        - Restart Apache RedHat
        - Restart Apache Debian

  - name: copy my HomePage to servers
    copy: src={{ source_folder }}/{{ item }} dest = {{ destin_folder }} mode=0555
#   with_fileglob: "{{ source_folder }}/*.*"
    loop:
        - "bahamas.png"
        - "bulgaria.png"
        - "jordan.png"
        - "newzeland.png"
    notify: 
        - Restart Apache RedHat
        - Restart Apache Debian

  handlers:
  - name: Restart Apache RedHat
    service: name=httpd state=restarted
    when: ansible_os_family == "RedHat"
  - name: Restart Apache Debian
    service: name=apache2 state=restarted
    when: ansible_os_family != "RedHat"
```
