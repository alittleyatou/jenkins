官网语法解释：https://jenkins.io/doc/book/pipeline/syntax/ 
翻译的比较详细的博客：https://www.cnblogs.com/YatHo/p/7856556.htm



#支持两种语法：Declarative Pipeline（声明式pipeline）和Scripted Pipeline（脚本pipeline）

共同点：
　　两者都是pipeline代码的持久实现，都能够使用pipeline内置的插件或者插件提供的steps，两者都可以利用共享库扩展。
区别：
　　两者不同之处在于语法和灵活性。Declarative pipeline对用户来说，语法更严格，有固定的组织结构，更容易生成代码段，使其成为用户更理想的选择。但是Scripted pipeline更加灵活，因为Groovy本身只能对结构和语法进行限制，对于更复杂的pipeline来说，用户可以根据自己的业务进行灵活的实现和扩展。


#选择使用Declarative Pipeline 的原因：

是后续Open Blue Ocean所支持的类型。相对而言，Declarative Pipeline比较简单，Declarative Pipeline中，也是可以内嵌Scripted Pipeline代码的。

使用Declarative Pipeline需要安装插件： pipeline：Declarative

支持的方法会不定时更新，可关注插件的介绍页面：https://wiki.jenkins.io/display/JENKINS/Pipeline+Model+Definition+Plugin



插件的语法不会写没有关系，Pipeline Syntax中直接生成。



#仅作代码格式参考，无实际意义：

pipelin {
    agent any;
                  //agent可放在pipeline或stage中，指定执行pipeline或stage的位置。
                  /*支持的参数为any（在任意可用的节点上执行pipeline）、none(每个stage部分将需要包含其自己的agent部分)、label(Jenkins环境中可用的代理上执行Pipeline或stage)、node、docker、dockerfile */
 
 
    environment { //定义环境变量，可理解为定义一些固定不变的值。使用方法：env.常量名。可用在pipline或stage中
          date="\$(date +%Y%m%d%H%M)" //获取当前时间戳
    }
 
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        }
    triggers {
        pollSCM('H 4 * * 1-5')//工作日每晚4点检查开发代码更新，若有更新则做构建
        cron（'H 4 * * 1-5'）//工作日每晚4点做daily build
        }
    parameters {  //参数，使用方法params.参数名[name]。
          booleanParam(name: 'all_build',description: '是否构建全部',defaultValue: false )//布尔值
          string(name:'email',defaultValue:'tangwy@gildata.com', description: '收件人邮箱' )//字符串
          choice(name: 'server',choices:'10.1.12.140\n blabla....', description: '部署服务器选择')//单选
          text(name: 'DEPLOY_TEXT', defaultValue: 'One\nTwo\nThree\n', description: '') //文本
          file(name: 'FILE', description: 'Some file to upload') //文件
          password(name: 'PASSWORD', defaultValue: 'SECRET', description: 'A secret password') //密码框
    }
     tools {//使用安装的工具，可在pipeline或stage中定义
           jdk 'JDK10'
          }
    stages{//stages中必须有stage
            stage('代码获取') {//stage中只能有一且仅有一个steps\stages\Parallel，但是被嵌套的stages中不能再包含更深层的stages和parallel
                when{
                        anyOf{equals expected: true, actual: params.all_build; environment name: 'date', value: '2018'}
                    }
                steps {
                }
            }
            stage('svn提交修改的版本号'){
                when{
                    anyOf{equals expected: true, actual: params.all_build; environment name: 'date', value: '2018' }
                    }
                steps {
                     echo "${env.date}+${params.email}"
                     sh('')
                     script{//可写groovy脚本
                }
                     sh("...${env.date}+${params.email}...")
                              }
                        }
                }
            }
            stage('打包') {
                when{
                    equals expected: true, actual: params.build
                    }
                agent{label "10.1.12.109-gup-开发"}
                environment {
                        name='亲爱的开发者~'
                  }
                tools {
                     maven 'apache-maven-3.0.1'
                      }
               
                     }
                parallel {
                        stage(A){
                            agent {label "for-branch-c"}
                            stages{
                                stage('1'){steps{}}
                                stage('2'){steps{}}
                                }  
                        stage(B){
                                steps{}
                                }
                    }  
                        }
             
        }
 post{//stage只要有一个出错，则后面的stage全部停止。post则无论stage什么状态都会执行。
        failure{
            script {   }
         }
     }
 
 
 
 
}
实际样例:

pipeline {
    agent any
        //参数化变量，目前只支持[booleanParam, choice, credentials, file, text, password, run, string]这几种参数类型，其他高级参数化类型还需等待社区支持。
    parameters {
     
  booleanParam(name: 'all_build',description: '是否构建全部',defaultValue: false )
  booleanParam(name: 'cam_build',description: '是否构建cam',defaultValue: false )
  booleanParam(name: 'dd_build',description: '是否构建dd',defaultValue: false )
  booleanParam(name: 'hub_build',description: '是否构建hub',defaultValue: false )
  booleanParam(name: 'test',description: '是否单元测试',defaultValue: false )
  //若勾选在pipelie完成后会邮件通知测试人员进行验收
  booleanParam(name: 'email_commit',description: '是否邮件通知人员构建结果',defaultValue: false )
  string(name:'email',defaultValue:'tangwy@gildata.com', description: '收件人邮箱' )
  //部署的服务器
  choice(name: 'server',choices:'10.1.12.140\n blabla....', description: '部署服务器选择')
    }
 
    
    //常量参数，初始确定后一般不需更改
    environment{
 
        name='小仙女'
    }
    options {
        //保持构建的最大个数
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }
    //定期检查开发代码更新，工作日每晚4点做daily build
    //triggers {
    // pollSCM('H 4 * * 1-5')
    //}
    stages {
        stage('代码获取') {
            steps {
                checkout([$class: 'SubversionSCM', additionalCredentials: [], excludedCommitMessages: '', excludedRegions: '', excludedRevprop: '', excludedUsers: '', filterChangelog: false, ignoreDirPropChanges: false, includedRegions: '', locations: [[cancelProcessOnExternalsFail: true, credentialsId: 'tangwy', depthOption: 'infinity', ignoreExternalsOption: true, local: '.', remote: 'https://10.1.12.116/Gildata/GDaaS/branches/GUP/gup-dev@HEAD']], quietOperation: true, workspaceUpdater: [$class: 'UpdateUpdater']])
            }
         
        }
        stage('单元测试'){
             when{
       equals expected: true, actual: params.test
     }
            steps {
                  sh"mvn clean install -f gup-exchange-model/pom.xml -Dmaven.test.skip=true"
                sh"mvn clean install -f gup-core/pom.xml -Dmaven.test.skip=true"
               
              echo "starting unitTest......"
              //注入jacoco插件配置,clean test执行单元测试代码. All tests should pass.
               
            sh " mvn org.jacoco:jacoco-maven-plugin:prepare-agent -f gup-dd/pom.xml clean test -Dmaven.test.failure.ignore=true"
     junit '**/target/surefire-reports/*.xml'
            }
        }
        stage('打包'){
             
    parallel {
        
    stage('all_build')
    {
       when{
       equals expected: true, actual: params.all_build
     }
      
     steps{
       sh"cd ${workspace}/gup-cam/&&npm install&&bower install --allow-root"
       sh"cd ${workspace}/gup-dd/&&npm install&&bower install --allow-root"
        sh"cd ${workspace}/gup-hub/&&npm install&&bower install --allow-root"
       sh"mvn package -Dmaven.test.skip=true"
     }
    }
    
    stage('cam_build')
    {
     when{
       equals expected: true, actual: params.cam_build
     }
     steps{
      sh"cd ${workspace}/gup-cam/&&npm install&&bower install --allow-root"
       sh"mvn package -f gup-cam/pom.xml -Dmaven.test.skip=true"
     }
    }
    stage('dd_build')
    {
         when{
       equals expected: true, actual: params.dd_build
     }
     steps{
      sh"cd ${workspace}/gup-dd/&&npm install&&bower install --allow-root"
       sh"mvn package -f gup-dd/pom.xml -Dmaven.test.skip=true"
     }
    }
    stage('hub_build')
    {
     when{
       equals expected: true, actual: params.hub_build
     }
     steps{
        sh"cd ${workspace}/gup-hub/&&npm install&&bower install --allow-root"
       sh"mvn package -f gup-hub/pom.xml -Dmaven.test.skip=true"
     }
    }
   }
        }
        stage('部署 '){
   input {
                message "需要部署吗？"
                ok "需要"
                parameters {
                    string(name: 'PERSON', defaultValue: 'Mr Jenkins', description: 'Who should I say hello to?')
                }
            }
    
            steps{
                  script {
                     echo params.deploy
                     def a=params.deploy.split(",")
                     for(int i in a) {
      def b="${i}"
                        sh" scp ${workspace}/${b}/target/*.war root@10.1.12.140:/twy/jenkins-test/new/${b}"
      sh""" ssh 10.1.12.140 "cd /twy/jenkins-test/apache-tomcat-8.0.28_${b}/bin&&./shutdown.sh" """
      sh""" ssh 10.1.12.140 rm -rf /twy/jenkins-test/${b}/* """
      sh""" ssh 10.1.12.140 "unzip -oq /twy/jenkins-test/new/${b}/*.war -d /twy/jenkins-test/${b}" """
      sh""" ssh 10.1.12.140 "cd /twy/jenkins-test/apache-tomcat-8.0.28_${b}/bin&&./startup.sh" """
      sh""" ssh 10.1.12.140 rm -rf /twy/jenkins-test/new/${b}/* """
       
                            }
                        }
        }
        }
    }
     post{
        success{
            script {
                 
                mail to: "${params.email}",
                subject: "PineLine '${JOB_NAME}' (${BUILD_NUMBER}) result",
                body: "hi~${env.name}\n pineline '${JOB_NAME}' (${BUILD_NUMBER}) run success\n请及时前往${env.BUILD_URL}进行查看"
                 
            }
        }
        failure{
            script {
                
                mail to: "${params.email}",
                subject: "PineLine '${JOB_NAME}' (${BUILD_NUMBER}) result",
                body: "hi~${env.name}\n pineline '${JOB_NAME}' (${BUILD_NUMBER}) run failure\n请及时前往${env.BUILD_URL}进行查看"
                 
            }
 
        }
        unstable{
            script {
                 
                mail to: "${params.email}",
                subject: "PineLine '${JOB_NAME}' (${BUILD_NUMBER})结果",
                body: "hi~${env.name}\n pineline '${JOB_NAME}' (${BUILD_NUMBER}) run unstable\n请及时前往${env.BUILD_URL}进行查看"
                 
            }
        }
    }
}