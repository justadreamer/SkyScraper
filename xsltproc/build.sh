DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

cd ../libxslt-with-plugins
./build.sh
cd -

xcodebuild

cp build/Release/xsltproc .
cp xsltproc ~/bin/xsltproc
