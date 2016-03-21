# Customize the Workbench Image
You can customize the workbench image by modifying the files in the `template` directory.  For example, you can install the `pymongo` and `python-twitter` Python libraries by adding the following lines to the bottom of the Dockerfile:

```
RUN pip install \
    pymongo==3.2.1 \
    python-twitter==2.2
```

Once you modify the Dockerfile, you need to rebuild the image and restart the notebook container before the changes will take effect.

```
# rebuild the notebook image
sh build.sh

# restart the notebook container
sh stop.sh
sh start.sh
```
