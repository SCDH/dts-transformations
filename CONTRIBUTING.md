# Contributing

All contributions are welcome:

- issues
- pull requests that fix issues (issue first, then pr)
- documentation and use cases in the Wiki
- stars/likes

## Development Cycle

### Tooling

The repo offers a reproducible tooling environment based on
[Tooling](https://github.com/SCDH/tooling). Afer cloning the repo,
`cd` into it and run:

```shell
./mvwn package
```

After this, tooling for XML and RDF processing is under `target/lib/`
and `target/bin/` contains nice wrapper scripts for Saxon HE, Apache
Ant, Apache Jena RIOT's command line tools, etc.


### Testing and Development

There are tests based on [`XSpec`](https://github.com/xspec/xspec) in
`test/xspec`. The tests can easily be run with maven from the root
directory of the repository:

Once set up the classpath:

```shell
./mvnw package
```

Then run all the tests:

```shell
target/bin/test.sh
```

Or, after setting the classpath by `source target/bin/classpath.sh`
run:

```{shell}
ant test
```

Try to write **small** assertions, not assertions on the whole output.

We prefer XSLT packages over stylesheets, because they are much more
flexible.


### Releasing

Releases of installable packages will be created with github actions
on tags with a name matching the pattern
`[0-9]+\.[0-9]+\.[0-9]+(-.*)?`,
i.e. `<MAJOR>.<MINOR>.<BUGFIX>[-<SUFFIX>]`. But only tags matching the
pattern `[0-9]+\.[0-9]+\.[0-9]+` will result in an update of the
descriptor file.--So, releases with a suffix are considered kind of
beta and will only occur in the tag's release bundle.

To produce a release:

- first push the branch to be released
- then tag it with the tag name matching the above pattern

This will produce a release on [releases/tag/<TAG_NAME>](releases/tag)
and update the [descriptor
file](https://scdh.github.io/dts-transformations/descriptor.xml).

NOTE: Git release tags are the single source of truth for release
numbers and release triggers. There is no version information in the
pom file. A default version number is contained in
`.mvn/maven.config`, which should be kept up to date. However, it is
overridden in the CI/CD pipelines by the release tag.


## XSLT in this Project

### Debug Messages

When adding debugging output with `<xsl:message>`, we use the
`use-when` compile-time switch to turn on/off debugging:

```xml
<xsl:message use-when="system-property('debug') eq 'true'">
  ...
</xsl:message>
```

The Saxon [wrapper script](scripts/xslt.sh) available in
`target/bin/xslt.sh` is aware of this.

To turn on debugging, say:

```shell
export DEBUG=true
```

To turn off debugging, say:

```shell
unset DEBUG
```

### Naming of Variables

We do not pre- or suffix variable and parameter names by type or
tunnel-kind. The compiler helps with all this.


## Community tests

Check out the repo to `cases`:

```shell
git clone https://gist.github.com/d1476d00e07969685df5856518cdd053.git cases
```

```shell
cd cases
```

Make output for test cases:

```shell
python3 run.py -i cases.tsv -d '../test/document.sh' -n '../test/navigation.sh' -p equals
```
