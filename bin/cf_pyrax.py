#!/usr/bin/python
import pyrax
import os

# Set variables for the various options
username  = os.environ['SDK_USERNAME']
apikey    = os.environ['SDK_TOKEN']
region    = os.environ['SDK_REGION']
folder    = os.environ['SRC']
container = os.environ['DST']

# Set the default region
pyrax.set_default_region(region)
# Set the default encoding
pyrax.encoding = "utf-8"
# Set the identity type to rackspace
# added to this file on 18 June 2013 re: https://github.com/rackspace/pyrax/issues/79
pyrax.set_setting("identity_type", "rackspace")
# Set my credentials
pyrax.set_credentials(username, apikey)
# Initiate the Cloud Files connection
cf_ord = pyrax.cloudfiles

# Upload the entire folder to the cloud files container.
print("Syncing all objects to %s container from folder %s." %
      (container, folder))
cf_ord.sync_folder_to_container(folder, container, delete=True,
                                include_hidden=True, ignore_timestamps=True)
print "Sync complete."
