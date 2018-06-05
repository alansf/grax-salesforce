![GRAX by Harding Point](https://static.wixstatic.com/media/fa96ca_4cb02045be8445468545da7de475da38~mv2.png/v1/fill/w_334,h_128,al_c,usm_0.66_1.00_0.01/fa96ca_4cb02045be8445468545da7de475da38~mv2.png)

# GRAX Salesforce SDK [![Build Status](https://travis-ci.org/HardingPoint/grax-salesforce.svg?branch=master)](https://travis-ci.org/HardingPoint/grax-salesforce)


[GRAX](https://www.grax.io/) Salesforce SDK uses your Salesforce instance(s) to build, power, and synchronize your enterprise graph. The power of your enterprise graph is the extensibility, flexibility, and fluidity to relate micro events to measure and correlate outcome (revenue, costs, risk, etc). Everything from multi channel marketing events, buying pattern awareness/alerts, to recognizing risks in customer service patterns. It all starts with building your enterprise graph from your existing Salesforce then extending.  

---------------------------------------------------------------------------------------------------------
## Installation

For detailed installation instructions with pictures & videos please visit [our website](https://www.grax.io/try-now)

For any questions, please contact us at support@grax.io

With a few clicks you can deploy GRAX for Salesforce, synchronize your enterprise graph, and begin to utilize flow.

1. <a href="https://developer.salesforce.com/signup">Create a Salesforce Developer Org</a>
	
	<i>(Skip to the next step if you have one)</i>

1. <a href="https://deploytosalesforce.herokuapp.com?owner=HardingPoint&repo=grax-salesforce">
	  <img alt="Deploy to Salesforce"
	       src="https://deploytosalesforce.herokuapp.com/resources/img/deploy-to-salesforce3.png">
	</a>
	
1. Make sure that the username and organization matches with what you've logged in with. 
1. Click Deploy 

1. Configure GRAX

	1. <a href="https://login.salesforce.com/one/one.app#/n/GRAX_DEPLOY">Configure Production or Developer Instance</a>
	1. <a href="https://test.salesforce.com/one/one.app#/n/GRAX_DEPLOY">Configure Sandbox</a>


## Manual Installation

Below are the instructions to deploy GRAX to any Salesforce environment.

1. Clone this repository from GitHub using the following command:

    ```bash
    git clone https://github.com/HardingPoint/grax-salesforce && cd grax-salesforce

1. Convert the source code:

    ```bash
    rm -rf ./mdapioutput && sfdx force:source:convert -d mdapioutput/
    ```

1. Authenticate the Salesforce DX CLI to the target environment:

    ```bash
    
    sfdx force:auth:web:login -a <ALIAS> -r <INSTANCEURL>
   
    ```
    In the browser window that opens, sign in to your org with your credentials. More information [here](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_auth_web_flow.htm)

1. Deploy the source code:

    ```bash
    
    sfdx force:mdapi:deploy -d mdapioutput/ -w 100 -u <ALIAS>
    
    ```

### GRAX Development

Open use Force IDE 2 or deploy to scratch org using commands below.

1. Clone this repository from GitHub using the following command:

    ```bash
    git clone https://github.com/HardingPoint/grax-salesforce && cd grax-salesforce

1. Create a new scratch environment or use IDE.

    ```bash
    sfdx force:org:create -a grax-sdk -s -f config/developer-scratch-def.json
    ```

1. Push the source to the scratch environment or use IDE

    ```bash
    sfdx force:source:push
    ```    
    
### Having Isues? 
Below are a few helpful commands to analyze your SFDX environment to look for issues.


	sfdx force:org:list
	
	sfdx force:alias:list


