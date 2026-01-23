import boto3
from datetime import datetime, timedelta


REGION = "ap-south-1"   
TAG_KEY = "CreatedWith"
TAG_VALUE = "Terraform"
TIME_FORMAT = "%Y-%m-%d"

# Last full month
today = datetime.utcnow()
first_day_of_this_month = today.replace(day=1)
last_day_of_last_month = first_day_of_this_month - timedelta(days=1)
first_day_of_last_month = last_day_of_last_month.replace(day=1)

start = first_day_of_last_month.strftime(TIME_FORMAT)
end = last_day_of_last_month.strftime(TIME_FORMAT)

# --------------------------
# AWS clients
# --------------------------
ce = boto3.client("ce", region_name="us-east-1")  # Cost Explorer is global
tagging = boto3.client("resourcegroupstaggingapi", region_name=REGION)

# --------------------------
# Step 1: List all resources with the tag
# --------------------------
def list_tagged_resources(tag_key, tag_value):
    resources = []
    paginator = tagging.get_paginator("get_resources")
    for page in paginator.paginate(
        TagFilters=[{"Key": tag_key, "Values": [tag_value]}],
        ResourcesPerPage=50
    ):
        resources.extend(page["ResourceTagMappingList"])
    return resources

tagged_resources = list_tagged_resources(TAG_KEY, TAG_VALUE)
print(f"\nFound {len(tagged_resources)} resources with tag {TAG_KEY}={TAG_VALUE}\n")

for r in tagged_resources:
    print(f"{r['ResourceARN']}")

# --------------------------
# Step 2: Get costs using Cost Explorer grouped by service
# --------------------------
def get_cost_by_tag(tag_key, tag_value, start, end):
    response = ce.get_cost_and_usage(
        TimePeriod={"Start": start, "End": end},
        Granularity="MONTHLY",
        Metrics=["BlendedCost"],
        Filter={
            "Tags": {
                "Key": tag_key,
                "Values": [tag_value]
            }
        },
        GroupBy=[{"Type": "DIMENSION", "Key": "SERVICE"}]
    )
    return response

cost_data = get_cost_by_tag(TAG_KEY, TAG_VALUE, start, end)

# --------------------------
# Step 3: Display cost per service
# --------------------------
print(f"\nAWS Cost Report for tag {TAG_KEY}={TAG_VALUE} from {start} to {end}:\n")
total = 0
for result in cost_data["ResultsByTime"]:
    for group in result["Groups"]:
        service_name = group["Keys"][0]
        cost = float(group["Metrics"]["BlendedCost"]["Amount"])
        total += cost
        print(f"{service_name}: ${cost:.2f}")

print(f"\nTotal estimated cost: ${total:.2f}")
