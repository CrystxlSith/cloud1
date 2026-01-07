INVENTORY = inventory.yml
PLAYBOOK = playbook.yaml
CLEANUP = cleanup.yaml

all: deploy

deploy:
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK)

clean:
	ansible-playbook -i $(INVENTORY) $(CLEANUP)

re: clean deploy

check:
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK) --check

ping:
	ansible -i $(INVENTORY) all -m ping

syntax:
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK) --syntax-check

list:
	ansible-inventory -i $(INVENTORY) --list

security:
	@echo "=== Testing UFW status ==="
	ansible -i $(INVENTORY) all -m shell -a "ufw status verbose"
	@echo ""
	@echo "=== Testing MariaDB port (should fail/timeout) ==="
	@for host in $$(ansible-inventory -i $(INVENTORY) --list | grep ansible_host | cut -d'"' -f4); do \
		echo "Testing $$host:3306..."; \
		nc -zv -w 3 $$host 3306 2>&1 || echo "✓ Port 3306 blocked on $$host"; \
	done

.PHONY: all deploy clean re check ping syntax list security
