# EGL AWS Report Tagable Resources/Services/Objects Utility

This shell script reports all tagable resources/services/objects for all AWS services in all AWS regions.

This utility produces reports that:

* Answer the question: "What tagable resources/services/objects do we have in this AWS account?"
* Create an audit trail of AWS tagable resources/services/objects count by region 

This utility provides tagable resources/services/objects count by region functionality unavailable in the AWS console or directly via the AWS CLI API. 

This utility can: 

* Capture the current count and list of all tagable AWS resources/services/objects in all AWS regions
* Write the counts and list to report.txt files   

This utility produces a summary report including:

* AWS account and alias
* The number of regions 
* The number of tagable resources
* The number of tags
* The number of tagable resources/services/objects per service per AWS Region
* The number of tagable resources/services/objects per AWS Region 

This utility produces a detail report including:

* AWS account and alias
* The number of regions 
* The number of tagable resources
* The number of tags
* The number of tagable resources/services/objects per service per AWS Region
* List of tagable resources/services/objects

This utility produces a list report including:

* List of tagable resources/services/objects


## Getting Started

1. Instantiate a local or EC2 Linux instance
2. Install or update the AWS CLI utilities
    * The AWS CLI utilities are pre-installed on AWS EC2 Linux instances
    * To update on an AWS EC2 instance: `$ sudo pip install --upgrade awscli` 
3. Create an AWS CLI named profile that includes the required IAM permissions 
    * See the "[Prerequisites](#prerequisites)" section for the required IAM permissions
    * To create an AWS CLI named profile: `$ aws configure --profile MyProfileName`
    * AWS CLI named profile documentation is here: [Named Profiles](http://docs.aws.amazon.com/cli/latest/userguide/cli-multiple-profiles.html)
4. Install the [bash](https://www.gnu.org/software/bash/) shell
    * The bash shell is included in most distributions and is pre-installed on AWS EC2 Linux instances
5. Download this utility script or create a local copy and run it on the local or EC2 Linux instance
    * Example: `$ bash ./aws-services-tagable-resources.sh -p AWS_CLI_profile`  

## [Prerequisites](#prerequisites)

* [bash](https://www.gnu.org/software/bash/) - Linux shell 
* [AWS CLI](https://aws.amazon.com/cli/) - command line utilities (pre-installed on AWS AMIs) 
* AWS CLI profile with IAM permissions for the AWS CLI commands:
  * aws ec2 describe-regions (used to pull list of regions )
  * aws sts get-caller-identity (used to pull account number )
  * aws iam list-account-aliases (used to pull account alias )
  * aws resourcegroupstaggingapi get-resources  


## Deployment

To execute the utility:

  * Example: `$ bash ./aws-services-tagable-resources.sh -p AWS_CLI_profile`  

To directly execute the utility:  

1. Set the execute flag: `$ chmod +x aws-services-tagable-resources.sh`
2. Execute the utility  
    * Example: `$ ./aws-services-tagable-resources.sh -p AWS_CLI_profile`    

## Output

* Summary report 
* Detail report
* List report
* Debug log (execute with the `-g y` parameter)  
  * Example: `$ bash ./aws-services-tagable-resources.sh -p AWS_CLI_profile -g y`  
* Console verbose mode (execute with the `-b y` parameter)  
  * Example: `$ bash ./aws-services-tagable-resources.sh -p AWS_CLI_profile -b y`  

## Contributing

Please read [CONTRIBUTING.md](https://github.com/Enterprise-Group-Ltd/aws-services-tagable-resources/blob/master/CONTRIBUTING.md) for  the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. 

## Authors

* **Douglas Hackney** - [dhackney](https://github.com/dhackney)

## License

This project is licensed under the MIT License - see the [LICENSE.md](https://github.com/Enterprise-Group-Ltd/aws-services-tagable-resources/blob/master/LICENSE) file for details

## Acknowledgments

* AWS support provided a code snippet for the AWS CLI API command 'aws resourcegroupstaggingapi get-resources' which inspired this utility 
* [Progress bar](https://stackoverflow.com/questions/238073/how-to-add-a-progress-bar-to-a-shell-script)  
* [Dynamic headers fprint](https://stackoverflow.com/questions/5799303/print-a-character-repeatedly-in-bash)
* [Menu](https://stackoverflow.com/questions/30182086/how-to-use-goto-statement-in-shell-script)
* Countless other jq and bash/shell man pages, Q&A, posts, examples, tutorials, etc. from various sources  

