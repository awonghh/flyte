from flytekit import task, workflow

@task
def process_dataset(dataset_name: str) -> str:
    # This function runs inside an isolated container on your EKS nodes
    return f"Successfully initialized processing for the {dataset_name} dataset on EKS!"

@workflow
def data_workflow(dataset_name: str = "MD17") -> str:
    # Workflows orchestrate the order in which tasks execute
    return process_dataset(dataset_name=dataset_name)

if __name__ == "__main__":
    # Allows you to test locally before sending to the cluster
    print(data_workflow())
