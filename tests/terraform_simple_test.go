package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformSimpleDatabricksClusterDeployment(t *testing.T) {

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./fixtures/simple-databricks-cluster",
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	output := terraform.OutputAll(t, terraformOptions)

	assert.Equal(t, output["expected_standard_name"], output["actual_standard_name"])
	assert.Equal(t, output["expected_single_node_name"], output["actual_single_node_name"])
	assert.Equal(t, output["expected_high_concurrency_name"], output["actual_high_concurrency_name"])
}
