## Example-8 (Roles)

 - ansible-galaxy init deploy_apache_web


### Structure of directories
```
.
├── README.md
└── deploy_apache_web
    ├── README.md
    ├── defaults
    │   └── main.yml
    ├── files
    ├── handlers
    │   └── main.yml
    ├── meta
    │   └── main.yml
    ├── tasks
    │   └── main.yml
    ├── templates
    ├── tests
    │   ├── inventory
    │   └── test.yml
    └── vars
        └── main.yml
```



Распилим playbook.yml по этим файликам
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


### New Structure of directories
```
.
├── README.md
└── deploy_apache_web
    ├── README.md
    ├── defaults
    │   └── main.yml
    ├── files
    │   ├── bahamas.png
    │   ├── jordan.png
    │   ├── newzeland.png
    │   └── bulgaria.png
    ├── handlers
    │   └── main.yml
    ├── meta
    │   └── main.yml
    ├── tasks
    │   └── main.yml
    ├── templates
    │   └── index.j2
    ├── tests
    │   ├── inventory
    │   └── test.yml
    └── vars
        └── main.yml
```


### defaults/main.yml
```
destin_folder: /var/www/html
```
### hadlers/main.yml
```
- name: Restart Apache RedHat
  service: name=httpd state=restarted
  when: ansible_os_family == "RedHat"
- name: Restart Apache Debian
  service: name=apache2 state=restarted
  when: ansible_os_family != "RedHat"
```
### tasks/main.yml
```
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
  template: src=index.j2 dest={{ destin_folder }}/index.html mode=0555
  notify: 
      - Restart Apache RedHat
      - Restart Apache Debian

- name: copy my HomePage to servers
  copy: {{ item }} dest = {{ destin_folder }} mode=0555
#   with_fileglob: "{{ source_folder }}/*.*"
  loop:
      - "bahamas.png"
      - "bulgaria.png"
      - "jordan.png"
      - "newzeland.png"
  notify: 
      - Restart Apache RedHat
      - Restart Apache Debian
```


### playbook.yml
```
---
- name: Install Apache and upload my Web page
  hosts: all
  become: yes

  roles:
    - { role: deploy_apache_web, when: ansible_system == "Linux" }
```



## Example-9 (extra-vars)

### hosts.txt
```
[PROD]
linux1 ansible_host=172.31.3.113  owner=Petya

[STAGING]
linux3 ansible_host=172.31.19.251  owner=Vasya

[ALL_LINUX:children]
PROD
STAGING
```

### playbook.yml
```
---
- name: Install Apache and upload my Web page
  hosts: "{{ MYHOSTS }}"
  become: yes

  roles:
    - { role: deploy_apache_web, when: ansible_system == "Linux" }
```

 - ansible-playbook playbook.yml --extra-var "MYHOSTS=STAGING owner=Denys"  
вместо --extra-var можно писать --extra-vars, -e  
переменные переданные таким путем самые приоритетные




## Example-10 (include, imports)


### playbook.yml
```
---
- name: My super Playbook
  hosts: all
  become: yes

  vars:
    mytext: "Privet from Andrey"

  tasks:
  - name: Ping test
    ping:

  - name: Create Folders
    include: create_folders.yml mytext="Hello world"

  - import: create_files.yml
```

### create_folders.yml
```
---
- name: Create folder1
  file:
    path: /home/secret/folder1
    state: directory
    mode: 0755

- name: Create folder2
  file:
    path: /home/secret/folder2
    state: directory
    mode: 0755
```

### create_files.yml
```
---
- name: Create file1
  copy:
    dest: /home/secret/file1.txt
    content: |
      TEXT Line1, in file1
      TEXT Line2, in file1
      TEXT Line3, in {{ mytext }}

- name: Create file2
  copy:
    dest: /home/secret/file2.txt
    content: |
      TEXT Line1, in file2
      TEXT Line2, in file2
      TEXT Line3, in {{ mytext }}
```




## Example-11 (delegate_to)


### playbook.yml
```
---
- name: My super Playbook
  hosts: all
  become: yes

  vars:
    mytext: "Vitayu tebe, miy Druzshe!"

  tasks:
  - name: Ping test
    ping:

  - name: Unregister Server from Load Balancer
    shell: echo this server {{ inventory_hostname }} was deregistered from out Load Balancer, node name is {{ ansible_nodename }} >> /home/log.txt
    delegate_to: 127.0.0.1

  - name: Update my Database
    shell: echo "UPDATING Database..."
    run_once: true  # эта таска выполнится один ран на одном сервере

  - name: Create file1
    copy:
      dest: /home/file1.txt
      content: |
        This is file1
        In ENGLISH Hello World
        On UKRAINIAN {{ mytext }}
    delegate_to: linux3

  - name: Create file2
    copy:
      dest: /home/file2.txt
      content: |
        This is file2
        In ENGLISH Hello World
        On UKRAINIAN {{ mytext }}

  - name: Reboot my servers
    shell: sleep 3 && reboot now
    async: 1
    poll: 0   # не держать сессию ssh

  - name: Wait till me server will come up online
    wait_for:
      host: "{{ inventory_hostname }}"
      state: started
      delay: 5
      timeout: 40
    delegate_to: 127.0.0.1

  - name: Register Server to Load Balancer
    shell: echo this server {{ inventory_hostname }} REGISTERED to Load Balancer, node name is {{ ansible_nodename }} >> /home/log.txt
    delegate_to: 127.0.0.1
```

delegate_to перенаправит выполнение на другой сервер.  

Рассмотрим case:  
 - Все серверы в load Balancere зарегестрированы
 - перед редактированием данных сервера (обновлением конфи и тд) нужно его отключить от балансироваки (чтобы на него не ходил трафик)  
Данный пример эмулирует эту ситуацию. На серверах перед выполнением происходит отключение их от балансировки, затем накатываются обновления, затем перегружается сервер, а затем опять включается в балансировку нагрузки.


## Example-12 (Errors)

### playbook.yml
```
---
- name: Ansible lesson
  hosts: all
#  any_errors_fatal: true
  become: yes

  tasks:
  - name: Task number 1
    yum: name=treeee state=latest  # <----, treee not found
    ignore_errors: yes

  - name: Task number 2
    shell: echo Hello World
    register: results
#    failed_when: "'World' in results.stdout"
    failed_when: results.rc != 0  # такое по умолчанию

  - debug:
      var: results

  - name: Task number 3
    shell: echo privet mir!!!
```


## Example-12 (Vault)

 - ansible-vault create mysecret.txt
 - ansible-vault view mysecret.txt
 - ansible-vault edit mysecret.txt
 - ansible-vault rekey mysecret.txt

### playbook.yml
```
---
- name: Ansible lesson
  hosts: all
  become: yes

  vars:
    admin_password: PASSW0rd1234@

  tasks:
  - name: Install package tree
    yum: name=tree state=latest

  - name: Create Config file
    copy:
      dest: "/home/ec2-user/myconfig.conf"
      content: |
        port = 9092
        log = 7days
        home = /opt/kafka/bin
        user = admin
        password = {{ admin_password }}
```

 - ansible-vault encrypt playbook.yml
зашифровать плэйбук
 - ansible-playbook playbook.yml --ask-vault-pass
 - ansible-playbook playbook.yml --vault-password-file mypass.txt
запустить зашифрованный плэйбук
 - ansible-vault view playbook.yml
 - ansible-vault decrypt playbook.yml
 - ansible-vault encrypt_string
 - echo -n "EGHJKECW" | ansible-vault encrypt_string
зашифровать строку  
Теперь вмето переменной в плэйбуке можно вставить <! vault | AHB123412340032...123847213> и получится зашифрованная переменная.


## Magic vars
 - {{ hostvars }}
 - {{ groups }}
 - {{ group_names }}
 - {{ inventory_hostname }}




