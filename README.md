unzip.aspx
==========

An ASP.NET unzip handler for serving files directly within ZIP archives without extracting them first.

```
http://yoursite.com/extjs.zip/resources/all.css
```
The above will doesn't work out of the box in IIS. A simple fix is to upload this unzip.aspx script and try again with:
```
http://yoursite.com/unzip.aspx/extjs.zip/resources/all.css
```

Now users can download the all.css file (with correct MIME types) without having to extract the entire extjs.zip package on the server first.

All files are served on the fly with no temp or cache files extracted anywhere. Browsers will cache based on Last-Modified HTTP header.
