export TEST_PATH=`pwd`
export JAVA_HOME=$TEST_PATH/java/jdk1.6.0_32
export PATH=$JAVA_HOME/bin:$PATH:.
export LD_LIBRARY_PATH=$JAVA_HOME/lib:$LD_LIBRARY_PATH

# goldilocks6.jar 는 직접 잡아주어야 합니다.
export CLASSPATH=$TEST_PATH/jar/json-simple-1.1.1.jar:$CLASSPATH
export CLASSPATH=$TEST_PATH/jar/log4j-1.2.15.jar:$CLASSPATH
export CLASSPATH=.:$CLASSPATH

