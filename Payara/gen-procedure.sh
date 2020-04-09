#!/bin/bash

VERSION=5.201
EL_VERSION=2.7.4.payara-p2

echo
echo \#
echo \# Let\'s patch payara-micro-${VERSION}.jar \(eclipselink-${EL_VERSION}\)
echo \#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#
echo
echo \# Create directories
echo mkdir -p $VERSION/ORI
echo cd $VERSION
echo
echo \# download payara-micro-X.YYY.jar from https://www.payara.fish/products/downloads/all-downloads/ in the current directory
echo \# then, make a copy
echo cp payara-micro-${VERSION}.jar ORI
echo
echo \# Extract Eclipselink core jar
echo unzip payara-micro-${VERSION}.jar MICRO-INF/runtime/org.eclipse.persistence.core.jar
echo
echo \# check eclipselink version:
echo unzip -p MICRO-INF/runtime/org.eclipse.persistence.core.jar META-INF/MANIFEST.MF \| grep Bundle-Version
echo
echo \# extract CollectionChangeRecord.class 
echo unzip MICRO-INF/runtime/org.eclipse.persistence.core.jar org/eclipse/persistence/internal/sessions/CollectionChangeRecord.class
echo
echo \# Check ORI files are the same
echo diff --report-identical-files org/eclipse/persistence/internal/sessions/CollectionChangeRecord.class ../../Eclipselink/${EL_VERSION}/ORI/CollectionChangeRecord-ORI.class
echo
echo \# override extracted class with patched one
echo cp ../../Eclipselink/${EL_VERSION}/CollectionChangeRecord-p1.class org/eclipse/persistence/internal/sessions/CollectionChangeRecord.class
echo
echo \# update eclipselink jar
echo zip MICRO-INF/runtime/org.eclipse.persistence.core.jar org/eclipse/persistence/internal/sessions/CollectionChangeRecord.class
echo
echo \# update payara jar
echo zip payara-micro-${VERSION}.jar MICRO-INF/runtime/org.eclipse.persistence.core.jar

echo \# update mvn albasim repository
echo mvn install:install-file -DgroupId=fish.payara.extras -DartifactId=payara-micro -Dversion=${VERSION}.albasim-p1 -Dfile=payara-micro-${VERSION}.jar  -Dpackaging=jar -DgeneratePom=true -DlocalRepositoryPath=../../repository  -DcreateChecksum=true



echo \# pom.xml
cat << EOF
    <dependency>
        <groupId>fish.payara.extras</groupId>
        <artifactId>payara-micro</artifactId>
        <version>${VERSION}.albasim-p1</version>
    </dependency>

  </repositories>
    <repository>
      <id>albasim-patched-externals</id>
      <name>AlbaSim Patched Externals</name>
      <!-- Online repository -->
      <!--<url>https://raw.github.com/Heigvd/Wegas_PatchedProjects/master/repository</url>-->
      <!-- Local repository -->
      <url>`realpath ../../repository`</url>
      <releases>
        <enabled>true</enabled>
      </releases>
      <snapshots>
        <enabled>false</enabled>
      </snapshots>
    </repository>
  </repositories>
EOF


echo \# TODO update wegas-core/src/test/resources/domain.xml and ./wegas-runtime/src/main/resources/domain.xml
