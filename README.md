
# READ ME 
This aspect of the project covers modules: 

 - The Cloud API 
 - The Cloud Client (Web App)
 
 ## Running on Local Machine
Prior to running this service on your local machine, please make sure that localhost:5000 is available. Failure to have this port available will result in a failure of service. This is to ensure that the Cloud API is in the correct communication point to interact with the web client. The Cloud Client, however, does not need to be on a specific port.

### Running the Cloud Client 
Prior to running locally, ensure that you have Node.js (and by extension npm) present on your machine. 
To run the cloud client, open a terminal via your machine or chosen IDE which can support npm queries. Direct the terminal to the View folder, as shown below:

    cd View
 Next, run a clean build of the project with the following command: 
 

    npm run build
 
 Should there be no adjustments needed, you can then run the webapp by running the following command:
 

    npm run start 
Once the service is running, you should see in the console a locally hosted site you can reach to view the web application. Depending on your machine's permissions, a browser may pop up with the web app loaded.

### Run the Cloud API 
To run the service on your local machine without containers, you should *ensure that you have Python 3.11 installed on your machine as a minimum* and that you have an IDE installed that can support interactions with Python, Such as PyCharm, which is what this was developed with. You should also ensure that all packages required to run the API backend are installed. This is done through the following script, which can be run in the terminal of your selected Python environment:

    pip install -r requirements.txt
 When all dependencies are present, you can then look to run the API. You can do this by selecting the "Main.py" file and running it via your IDE's run tool, if available. Alternatively, you can run the following script in a terminal running your Python environment. 

    python Controllers/ParentControllerInterface.py

From here, the service should run without any issues.
    

### Port Requirements
If running the service on a container, you will not need to consider which ports are available as it is expected that the container should have those ports available. To run on a container, ensure that your machine(s) have Docker / Podman installed to facilitate the containerisation environment. 
### Running the container

**Note(1):** The container scripts are written to support the deployment to the two VM's used for the assignment. This project is permitted to use CS5939-vm02.st-andrews.ac.uk for deployment. Please do not deploy it to any other services; otherwise, it will cause unexpected errors.


**Note(2):** The run scripts are designed for production deployments only.


### Build and running containers
The components of this system can be run on containers. As part of this assignment, we provide scripts in automating that process somewhat. All that is required of you is to open a terminal, redirect to wherever this project is being stored, and then run the following script:

    ./run.sh
If this is your first time running it, you might find you get a permission issue. If that is the case, then you need to make sure there is permission to run it on your machine. This can be done with the following command in the terminal

    chmod +x run.sh
### Loading the webapp into your local machine (when deployed to VM's) 
To access the web app for the server end of the service. You will first be required to carry out some SSH tunneling to achieve this. You can do this via the following command in the terminal: 
<Insert code here> 
You may be required to enter your VM's password to gain access. 
Please do not change the port numberings for this as they ensure all services can run at the same time on your device (via tunneling)
Once that is completed, you can then view the Monitoring dashboard webpage via the link below
<Insert Link>
