# brew install peco
# PECO

peco_assume_role_name() {
	cat ~/.aws/config | grep -e "^\[profile.*\]$" | peco
}

peco_format_aws_output_text() {
	peco_input=$1
	echo "${peco_input}" | tr "\t" "\n"
}

peco_aws_acm_list() {
	aws_acm_list | peco
}

peco_aws_input() {
	aws_cli_commandline="${1} --output text"
	result_cached=$2

	md5_hash=$(echo $aws_cli_commandline | md5)
	input_folder=${aws_cli_input_tmp}/${ASSUME_ROLE}
	mkdir -p ${input_folder}
	input_file_path="${input_folder}/${md5_hash}.txt"
	empty_file=$(find ${input_folder} -name ${md5_hash}.txt -empty)

	# The file is existed and not empty and the flag result_cached is not empty
	if [ -f "${input_file_path}" ] && [ -z "${empty_file}" ] && [ -n "${result_cached}" ]; then
		# Ignore the first line.
		grep -Ev "\*\*\*\*\*\*\*\* \[.*\]" $input_file_path
	else
		aws_result=$(eval $aws_cli_commandline)
		format_text=$(peco_format_aws_output_text $aws_result)

		if [ -n "${format_text}" ]; then
			echo "******** [ ${aws_cli_commandline} ] ********" >${input_file_path}
			echo ${format_text} | tee -a ${input_file_path}
		else
			echo "Can not get the data"
		fi

	fi
}

# AWS Logs
peco_aws_logs_list() {
	peco_aws_input 'aws logs describe-log-groups --query "*[].logGroupName"' 'true'
}

# AWS ECS
peco_aws_ecs_list_clusters() {
	peco_aws_input 'aws ecs list-clusters --query "*[]"' 'true'
}

peco_aws_ecs_list_services() {
	peco_aws_input 'aws ecs list-services --cluster $aws_ecs_cluster_arn --query "*[]"'
}

# AWS ECR

peco_aws_list_repositorie_names() {
	peco_aws_input 'aws ecr describe-repositories --query "*[].repositoryName"' 'true'
}

# AWS RDS
peco_aws_list_db_parameter_groups() {
	peco_aws_input 'aws rds describe-db-parameter-groups --query "*[].DBParameterGroupName"' 'true'
}

peco_aws_list_db_cluster_parameter_groups() {
	peco_aws_input 'aws rds describe-db-cluster-parameter-groups --query "*[].DBClusterParameterGroupName"' 'true'
}

peco_aws_list_db_clusters() {
	peco_aws_input 'aws rds describe-db-clusters --query "*[].DBClusterIdentifier"' 'true'
}

peco_aws_list_db_instances() {
	peco_aws_input 'aws rds describe-db-instances --query "*[].DBInstanceIdentifier"' 'true'
}

# Lambda
peco_aws_lambda_list() {
	peco_aws_input 'aws lambda list-functions --query "*[].FunctionName"' 'true'
}

# S3
peco_aws_s3_list() {
	peco_aws_input 'aws s3api list-buckets --query "Buckets[].Name"' 'true'
}

# Codebuild
peco_aws_codebuild_list() {
	peco_aws_input 'aws codebuild list-projects --query "*[]"' 'true'
}
