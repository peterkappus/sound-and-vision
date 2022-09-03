# Browser-based toys

These will run in a web browser, mostly using p5.js.

## Getting Started
To run these, you'll probably have to serve the files locally. 

### Python Simple Server
If you have python installed, you can use the simple server:

```
python -m SimpleHTTPServer 8000
```

Using python 3? Try this
```
python3 -m http.server 8000
```

Now open a browser to http://localhost:8000 and open up a specific folder to run the example..

### Using P5 Manager
You can also use [P5 manager](https://github.com/chiunhau/p5-manager) which includes LiveReload to see your changes instantly in the browser:

```
#first time setup
docker build -t p5manager .

# map ports for server and live-reload
# also mount the current directory to /app inside the container
docker run -it -p 8000:5555 -p 35729:35729 -v"$(PWD)":/app p5manager
```

Now open a browser to http://localhost:8000 and open up a specific folder.
