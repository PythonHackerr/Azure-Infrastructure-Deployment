ansible-playbook vm_creation.yml -i inventories/inventory$1.yml
ansible-playbook deploy.yml -i inventories/inventory$1.yml -i azure_rm.yml