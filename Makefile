########################################################################################################################
# RUN TESTS
########################################################################################################################
test-cruft-template-validation:
	$(info === Running tests: Cruft Template Validation ===)
	@cruft check
.PHONY: test-cruft-template-validation

test-code-validation:
	$(info === Running tests: Code Validation ===)
	@terraform init
	@terraform validate
.PHONY: test-code-validation

test-format-check:
	$(info === Running tests: Format Check ===)
	@terraform fmt -check
.PHONY: test-format-check

test-static-code-analysis: test-format-check test-cruft-template-validation
.PHONY: test-static-code-analysis

test-unit-test:
	$(info === Running tests: Automated Tests ===)
	@cd tests && go mod init test || true && go get -v -t -d && go mod tidy || true && go test -v -timeout 60m
.PHONY: test-unit-test

test: test-static-code-analysis test-unit-test
.PHONY: test

########################################################################################################################
# DOCUMENTATION GENERATION
########################################################################################################################
docs: docs-update-tf-inputs docs-update-tf-outputs docs-update-tf-modules docs-update-tf-providers docs-update-tf-requirements docs-update-tf-resources
.PHONY:docs

docs-update-tf-inputs:
	$(info === Generating docs: Terraform Inputs ===)
	@# Generate the docs
	@terraform-docs --sort-by required --show inputs markdown . | tail -n+3  > _temp_tfd_inputs.md
	@# Remove the old values
	@awk '/<<ii-tf-inputs-begin>>/,/<<ii-tf-inputs-end>>/ {if (!(/<<ii-/)) next}1' README.md > _temp_tfd_readme.md && mv _temp_tfd_readme.md README.md
	@# Insert the new values
	@awk '/<<ii-tf-inputs-begin>>/{print;system("cat _temp_tfd_inputs.md ");next}1' README.md > _temp_tfd_readme.md && mv _temp_tfd_readme.md README.md
	@rm -rf _temp_tfd*
.PHONY:docs-update-tf-inputs

docs-update-tf-outputs:
	$(info === Generating docs: Terraform Outputs ===)
	@# Generate the docs
	@terraform-docs --sort-by required --show outputs markdown . | tail -n+3  > _temp_tfd_outputs.md
	@# Remove the old values
	@awk '/<<ii-tf-outputs-begin>>/,/<<ii-tf-outputs-end>>/ {if (!(/<<ii-/)) next}1' README.md > _temp_tfd_readme.md && mv _temp_tfd_readme.md README.md
	@# Insert the new values
	@awk '/<<ii-tf-outputs-begin>>/{print;system("cat _temp_tfd_outputs.md ");next}1' README.md > _temp_tfd_readme.md && mv _temp_tfd_readme.md README.md
	@rm -rf _temp_tfd*
.PHONY:docs-update-tf-outputs

docs-update-tf-modules:
	$(info === Generating docs: Terraform Modules ===)
	@# Generate the docs
	@terraform-docs --sort-by required --show modules markdown . | tail -n+3  > _temp_tfd_modules.md
	@# Remove the old values
	@awk '/<<ii-tf-modules-begin>>/,/<<ii-tf-modules-end>>/ {if (!(/<<ii-/)) next}1' README.md > _temp_tfd_readme.md && mv _temp_tfd_readme.md README.md
	@# Insert the new values
	@awk '/<<ii-tf-modules-begin>>/{print;system("cat _temp_tfd_modules.md ");next}1' README.md > _temp_tfd_readme.md && mv _temp_tfd_readme.md README.md
	@rm -rf _temp_tfd*
.PHONY:docs-update-tf-modules

docs-update-tf-providers:
	$(info === Generating docs: Terraform Providers ===)
	@# Generate the docs
	@terraform-docs --sort-by required --show providers markdown . | tail -n+3  > _temp_tfd_providers.md
	@# Remove the old values
	@awk '/<<ii-tf-providers-begin>>/,/<<ii-tf-providers-end>>/ {if (!(/<<ii-/)) next}1' README.md > _temp_tfd_readme.md && mv _temp_tfd_readme.md README.md
	@# Insert the new values
	@awk '/<<ii-tf-providers-begin>>/{print;system("cat _temp_tfd_providers.md ");next}1' README.md > _temp_tfd_readme.md && mv _temp_tfd_readme.md README.md
	@rm -rf _temp_tfd*
.PHONY:docs-update-tf-providers

docs-update-tf-requirements:
	$(info === Generating docs: Terraform Requirements ===)
	@# Generate the docs
	@terraform-docs --sort-by required --show requirements markdown . | tail -n+3  > _temp_tfd_requirements.md
	@# Remove the old values
	@awk '/<<ii-tf-requirements-begin>>/,/<<ii-tf-requirements-end>>/ {if (!(/<<ii-/)) next}1' README.md > _temp_tfd_readme.md && mv _temp_tfd_readme.md README.md
	@# Insert the new values
	@awk '/<<ii-tf-requirements-begin>>/{print;system("cat _temp_tfd_requirements.md ");next}1' README.md > _temp_tfd_readme.md && mv _temp_tfd_readme.md README.md
	@rm -rf _temp_tfd*
.PHONY:docs-update-tf-requirements

docs-update-tf-resources:
	$(info === Generating docs: Terraform Resources ===)
	@# Generate the docs
	@terraform-docs --sort-by required --show resources markdown . | tail -n+3  > _temp_tfd_resources.md
	@# Remove the old values
	@awk '/<<ii-tf-resources-begin>>/,/<<ii-tf-resources-end>>/ {if (!(/<<ii-/)) next}1' README.md > _temp_tfd_readme.md && mv _temp_tfd_readme.md README.md
	@# Insert the new values
	@awk '/<<ii-tf-resources-begin>>/{print;system("cat _temp_tfd_resources.md ");next}1' README.md > _temp_tfd_readme.md && mv _temp_tfd_readme.md README.md
	@rm -rf _temp_tfd*
.PHONY:docs-update-tf-resources

delete-generated-docs:
	@awk '/<<ii-tf-.+-begin>>/,/<<ii-tf-.+-end>>/ {if (!(/<<ii-/)) next}1' README.md > _temp_tfd_readme.md && mv _temp_tfd_readme.md README.md
.PHONY:delete-generated-doc

########################################################################################################################
# CLEAN UP TASKS
########################################################################################################################
clean: delete-ds-store-files
.PHONY:clean

delete-ds-store-files:
	find . -name .DS_Store -print0 | xargs -0 git rm -f --ignore-unmatch
.PHONY:delete-ds-store-files
