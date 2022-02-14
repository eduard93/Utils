# Utils
Various code snippets for InterSystems Iris

## Installation with ZPM

If ZPM the current instance is not installed, then in one line you can install the latest version of ZPM.
```
s r=##class(%Net.HttpRequest).%New(),r.Server="pm.community.intersystems.com",r.SSLConfiguration="ISC.FeatureTracker.SSL.Config" d r.Get("/packages/zpm/latest/installer"),$system.OBJ.LoadStream(r.HttpResponse.Data,"c")
```

If ZPM is installed, then ZAPM can be set with the command
```
zpm:USER>install utils-code-snippets
```
## Installation with Docker

## Prerequisites
Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.

## Installation 
Clone/git pull the repo into any local directory

```
$ git clone https://github.com/eduard93/Utils
```

Open the terminal in this directory and run:

```
$ docker-compose build
```

3. Run the IRIS container with your project:

```
$ docker-compose up -d
```

## How to Test it
Open IRIS terminal:


```
$ docker-compose exec iris iris session iris
USER>set sql=##class(Utils.SQL).getSQL("Comments",0,.desc) write !,sql,!!,desc

SELECT
  c.cid                    AS Id,
  c.nid                    AS Nid,
...
  node.status = 1
  AND node.type IN ('code_package', 'documentation', 'learning_track', 'video', 'post')
GROUP BY c.cid


test query
stored in xdata
``` 