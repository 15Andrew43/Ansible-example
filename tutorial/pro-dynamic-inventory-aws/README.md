## Dynamic Inventory AWS

 - wget https://.../inventory/ec2.py
 - wget https://.../inventory/ec2.ini

создать юзера в амазоне, дать его права
 - AmazonEC2ReadOnlyAccess
 - AmazonElastiCacheReadOnlyAccess
 - AmazonRDSReadOnlyAccess

export AWS_ACCESS_KEY='veqvf'
AWS_SECRET_ACCESS_KEY='dfvgbwgr'


 - chmod +x ec2.py
 - ./ec2.py --list
 - ./ec2.py --list --refresh-cache
генерирует инвентори-файл в output

Для каждого тега сосдается масив серверов с таким тегом, для каждого региона и и тд.



### all
```
---
ansible_user : ec2-user
```

### us-west-1
```
---
ansible_private_key_file : /home/ec2-user/.ssh/keyadmin-us-west-1.pem
```

### eu-central-1
```
ansible_private_key_file : /home/ec2-user/.ssh/keyadmin-eu-central-1.pem
```

### ap-northeast-1
```
ansible_private_key_file : /home/ec2-user/.ssh/keyadmin-ap-northeast-1.pem
```




### Structure of directories
```
.
├── ansible.cfg
├── group_vars
│   ├── all
│   ├── us-west-1
│   ├── ap-northeast-1
│   └── eu-central-1
├── ec2.ini
└── ec2.py
```


### ansible.cfg
```
[defaults]
host_key_checking = false
```


 - ansible -i ec2.py all -m ping
 - ansible -i ec2.py tag_Env_STAGING -m ping



### playbook.yml
```
---
- name: Test Connection to linux
  hosts: tag_Env_PROD
  become: yes

  tasks:
  - ping:
```

 - ansible-playbook -i ec2.py playbook.yml




## Создание ресурсов

см сайт ансибм 

