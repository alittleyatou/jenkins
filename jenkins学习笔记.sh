官网语法解释：https://jenkins.io/doc/book/pipeline/syntax/ 
翻译的比较详细的博客：https://www.cnblogs.com/YatHo/p/7856556.htm

一、基础知识
{
#为什么要用 Pipeline?
{
代码: Pipeline以代码的形式实现,通常被检λ源代码控制,使团队能够编辑审查和迭代其CD流程。
可持续性: Jenkins重启或者中断后都不会影响 Pipeline Job
停顿: Pipeline可以选择停止并等待人工输入或批准,然后再继续 Pipeline运行。
多功能: Pipeline支持现实世界的复杂CD要求,包括fork/join子进程,循环和并行执行工作的能力。
可扩展: Pipeline插件支持其DSL的自定义扩展以及与其他插件集成的多个选项
}

#Multibranch Pipeline（多分支流水线）：
{
根据一个SCM仓库中检测到的分支创建一系列流水线}

#Pipeline支持两种语法
{
Declarative声明式（在Pipeline plugin2.5中引入）
Scripted Pipeline脚本式
}

#如何创建基本的Pipeline
{
1）直接在Jenkins Weeb UI网页界面中输入pipeline脚本
2）通过创建一个Jenkinsfile可以检入项目的源代码管理库
}

#最佳实践
{
推荐在Jenkins中直接从源代码控制（SCM）中见图Jenkinsfiles
}
}

——————————————————————————————————————————————————————————————————————————————————————————————
二、Declarative（声明式） Pipeline
{

#声明式pipeline的基本语法与groovy基本一致，但有以下例外：
{
1）声明式pipeline必须包含在固定格式pipeline{}块内；
2）每个声明语句必须独立一行，行位无需使用分号；
3）块（Blocks{}）只能包含Sections（章节）, Directives（指令）, Steps（步骤）或赋值语句。
4）属性引用语句被视为无参方法调用。所以例如，输入被视为input（）
}

#块（blocks{}）
{
由大括号括起来的语句，如：
pipeline{}，section{}，parameters{}，script{}
}

#章节（Sections）
{
Sections通常包含一个或多个Directives或 Steps
agent，post，stages，steps
}

#指令（Directives）
{
environment（环境变量），options（pipeline选项要求），paeameters（参数化构建），triggers（设置触发器），stage，tools，when
}

#步骤（steps）
{
Pipeline Steps reference：https://jenkins.io/doc/pipeline/steps/
执行脚本式pipeline：使用script{}
}

#agent
{
agent部分指定整个Pipeline或特定阶段将在Jenkins环境中执行的位置。
必须在pipeline块内的顶层定义 ，但stage级使用是可选的。
1）参数
{
any：在任何可用的agent上执行Pipeline或stage。例如：agent any
none：暂时不指定运行节点，每个stage部分将需要包含其自己的agent部分
label：例如：agent { label 'my-defined-label' }
node：agent { node { label 'labelName' } }，等同于 agent { label 'labelName' }，但node允许其他选项（如customWorkspace）。
docker：执行Pipeline或stage时会动态供应一个docker节点去接受Docker-based的Pipelines。
		docker还可以接受一个args，直接传递给docker run调用。例如：agent { docker 'maven:3-alpine' }或：
		docker
		agent {
			docker {
				image 'maven:3-alpine'
				label 'my-defined-label'
				args  '-v /tmp:/tmp'
			}
		}
dockerfile：使用从Dockerfile源存储库中包含的容器来构建执行Pipeline或stage 。为了使用此选项，Jenkinsfile必须从Multibranch Pipeline或“Pipeline from SCM“加载。
			默认是在Dockerfile源库的根目录：agent { dockerfile true }。
			如果Dockerfile需在另一个目录中建立，请使用以下dir选项：agent { dockerfile { dir 'someSubDir' } }。
			您可以通过docker build ...使用additionalBuildArgs选项，如agent { dockerfile { additionalBuildArgs '--build-arg foo=bar' } }。
}

2）常用选项
{
label
customWorkspace：一个字符串。自定义运行的工作空间内。它可以是相对路径，在这种情况下，自定义工作区将位于节点上的工作空间根目录下，也可以是绝对路径。例如：
				agent {
					node {
						label 'my-defined-label'
						customWorkspace '/some/other/path'
					}
				}
reuseNode：一个布尔值，默认为false。如果为true，则在同一工作空间中。此选项适用于docker和dockerfile，并且仅在 individual stage中使用agent才有效。
}
}
#post
{
1）使用方法
{
 post{//stage只要有一个出错，则后面的stage全部停止。post则无论stage什么状态都会执行。
        failure{
            script {   }
         }
     }
}

2）conditions项：
{
　　always
　　　　运行，无论Pipeline运行的完成状态如何。
　　changed
　　　　只有当前Pipeline运行的状态与先前完成的Pipeline的状态不同时，才能运行。
　　failure
　　　　仅当当前Pipeline处于“失败”状态时才运行，通常在Web UI中用红色指示表示。
　　success
　　　　仅当当前Pipeline具有“成功”状态时才运行，通常在具有蓝色或绿色指示的Web UI中表示。
　　unstable
　　　　只有当前Pipeline具有“不稳定”状态，通常由测试失败，代码违例等引起，才能运行。通常在具有黄色指示的Web UI中表示。
　　aborted
　　　　只有当前Pipeline处于“中止”状态时，才会运行，通常是由于Pipeline被手动中止。通常在具有灰色指示的Web UI中表示。
}
}

#stages
{
1）声明式pipeline中必须包含且只能有一个
2）通常位于agent或者options后面
}

#steps
{
1）包含一个或多个在stage块中执行的step序列。
2）仅有一个step的情况下可以省略steps{}下的step块
}

#environment:环境变量
{
该指令支持一种特殊的方法credentials()，可以通过其在Jenkins环境中的标识符来访问预定义的凭据。例如：
environment {
                AN_ACCESS_KEY = credentials('my-prefined-secret-text')
            }
}

#options
{
1）指令允许在Pipeline本身内配置Pipeline专用选项。
2）在一个pipeline中仅允许出现一次
3）可用选项
　　buildDiscarder
　　　　pipeline保持构建的最大个数。例如：options { buildDiscarder(logRotator(numToKeepStr: '1')) }
　　disableConcurrentBuilds
　　　　不允许并行执行Pipeline,可用于防止同时访问共享资源等。例如：options { disableConcurrentBuilds() }
　　skipDefaultCheckout
　　　　默认跳过来自源代码控制的代码。例如：options { skipDefaultCheckout() }
　　skipStagesAfterUnstable
　　　　一旦构建状态进入了“Unstable”状态，就跳过此stage。例如：options { skipStagesAfterUnstable() }
　　timeout
　　　　设置Pipeline运行的超时时间。例如：options { timeout(time: 1, unit: 'HOURS') }
　　retry
　　　　失败后，重试整个Pipeline的次数。例如：options { retry(3) }
　　timestamps
　　　　预定义由Pipeline生成的所有控制台输出时间。例如：options { timestamps() }
	pipeline {
		agent any
		options {
			timeout(time: 1, unit: 'HOURS')
		}
		stages {
			stage('Example') {
				steps {
					echo 'Hello World'
				}
			}
		}
	}　
}

#parameters
{
可用选项：目前只支持[booleanParam, choice, credentials, file, text, password, run, string]这几种参数类型
booleanParam：布尔类型（true，FALSE）
choice：单选
credentials：密钥
file：文件
text：文本
password：密码
run：运行
string：字符串
}

#triggers
{
Pipeline自动化触发的方式，目前只有两个可用的触发器：cron和pollSCM。
cron
　　接受一个cron风格的字符串来定义Pipeline触发的常规间隔，例如： triggers { cron('H 4/* 0 0 1-5') }
pollSCM
　　接受一个cron风格的字符串来定义Jenkins检查SCM源更改的常规间隔。如果存在新的更改，则Pipeline将被重新触发。例如：triggers { pollSCM('H 4/* 0 0 1-5') }
}

#tools
{
通过tools可自动安装工具，并放置环境变量到PATH。如果agent none，这将被忽略。
Supported Tools(Global Tool Configuration)
　　maven
　　jdk
　　gradle
pipeline {
    agent any
    tools {
        //工具名称必须在Jenkins 管理Jenkins → 全局工具配置中预配置。
        maven 'apache-maven-3.0.1'
    }
    stages {
        stage('Example') {
            steps {
                sh 'mvn --version'
            }
        }
    }
}
}

#when
{
根据给定的条件确定是否执行该阶段。
该when指令必须至少包含一个条件。
如果when指令包含多个条件，则所有子条件必须为stage执行返回true。
内置条件
　　branch
　　　　当正在构建的分支与给出的分支模式匹配时执行，例如：when { branch 'master' }。请注意，这仅适用于多分支Pipeline。
　　environment
　　　　当指定的环境变量设置为给定值时执行，例如： when { environment name: 'DEPLOY_TO', value: 'production' }
　　expression
　　　　当指定的Groovy表达式求值为true时执行，例如： when { expression { return params.DEBUG_BUILD } }
　　not
　　　　当嵌套条件为false时执行。必须包含一个条件。例如：when { not { branch 'master' } }
　　allOf
　　　　当所有嵌套条件都为真时执行。必须至少包含一个条件。例如：when { allOf { branch 'master'; environment name: 'DEPLOY_TO', value: 'production' } }
　　anyOf
　　　　当至少一个嵌套条件为真时执行。必须至少包含一个条件。例如：when { anyOf { branch 'master'; branch 'staging' } }
pipeline {
    agent any
    stages {
        stage('Example Build') {
            steps {
                echo 'Hello World'
            }
        }
        stage('Example Deploy') {
            when {
                allOf {
                    branch 'production'
                    environment name: 'DEPLOY_TO', value: 'production'
                }
            }
            steps {
                echo 'Deploying'
            }
        }
    }
}
}

#Parallel(并行)
{
Declarative Pipeline近期新增了对并行嵌套stage的支持，对耗时长，相互不存在依赖的stage可以使用此方式提升运行效率。除了parallel stage，单个parallel里的多个step也可以使用并行的方式运行。
pipeline {
    agent any
    stages {
        stage('Non-Parallel Stage') {
            steps {
                echo 'This stage will be executed first.'
            }
        }
        stage('Parallel Stage') {
            when {
                branch 'master'
            }
            parallel {
                stage('Branch A') {
                    agent {
                        label "for-branch-a"
                    }
                    steps {
                        echo "On Branch A"
                    }
                }
                stage('Branch B') {
                    agent {
                        label "for-branch-b"
                    }
                    steps {
                        echo "On Branch B"
                    }
                }
            }
        }
    }
}
}

#Scripted Pipeline
{
1）流程控制
{
{
pipeline脚本同其它脚本语言一样，从上至下顺序执行，它的流程控制取决于Groovy表达式，如if/else条件语句，举例如下：
Jenkinsfile (Scripted Pipeline)
node {
    stage('Example') {
        if (env.BRANCH_NAME == 'master') {
            echo 'I only execute on the master branch'
        } else {
            echo 'I execute elsewhere'
        }
    }
}
}
}

2）Groovy的异常处理机制
{
当任何一个步骤因各种原因而出现异常时，都必须在Groovy中使用try/catch/finally语句块进行处理，举例如下：
Jenkinsfile (Scripted Pipeline)
node {
    stage('Example') {
        try {
            sh 'exit 1'
        }
        catch (exc) {
            echo 'Something failed, I should sound the klaxons!'
            throw
        }
    }
}
}
}
}

三、jenkins常用辅助工具
{
1）代码生成器（Pipeline Syntax）
2）replay：可获取历史job的pipeline
3）pipeline语法参考手册（job-pipeline-syntax-Steps Reference）：包含当前jenkins已安装所有插件的pipeline说明
}

四、全局变量引用
{
#env
{
获取环境变量
env.path env.BUILD_ID
}

#params
{
获取参数化构建中配置的参数
params.JIRA_ISSUE_ID
params.script_dir
}

#currentBuild
{
引用当前运行的pipeline构建信息
}

#可用的所有全局变量信息
{
job/pipeline-syntax/globals
}

}

五、其他待学习拓展功能
{
可视化BlueOcean
pipeline可视化编辑器
命令行pipeline调试工具
}

六、复杂的pipeline功能
{
#变量传递
{
{
1）自定义变量def（局部）
{
def username = 'jenkins'
echo 'Hello Mr.${username}'
echo "Hello Mr.${username}"
打印结果
Hello Mr.${username}
Hello Mr.jenkins
}
}
2）环境变量withEnv（局部）
{
withEnv(['JIRA_SITE=wzzjira']) {
    echo 'jira issue key:'
    echo "${params.JIRA_ISSUE_KEY2}"
	}
此后此环境变量失效
}

3）环境变量（全局）environment——可出现多次
{
environment{CC = 'CLANG'}
echo "dd=${env.CC}"
}

4)参数化构建parameters（全局）
{
parameters {
string(name:'client_version',defaultValue:'', description: '请填写客户端版本号')
echo "${params.client_version}"
}
}
}
#判断when——仅用于stage内部
{
内置条件
　　branch
　　　　当正在构建的分支与给出的分支模式匹配时执行，例如：when { branch 'master' }。请注意，这仅适用于多分支Pipeline。
　　environment
　　　　当指定的环境变量设置为给定值时执行，例如： when { environment name: 'DEPLOY_TO', value: 'production' }
　　expression
　　　　当指定的Groovy表达式求值为true时执行，例如： when { expression { return params.DEBUG_BUILD } }
　　not
　　　　当嵌套条件为false时执行。必须包含一个条件。例如：when { not { branch 'master' } }
　　allOf
　　　　当所有嵌套条件都为真时执行。必须至少包含一个条件。例如：when { allOf { branch 'master'; environment name: 'DEPLOY_TO', value: 'production' } }
　　anyOf
　　　　当至少一个嵌套条件为真时执行。必须至少包含一个条件。例如：when { anyOf { branch 'master'; branch 'staging' } }
}

#循环
{
for循环仅存在于script pipeline中，声明式需要使用可用script{}调用
}

#并行

#人工确认input
{
样例1:submitter中限制了必须是BossId才可以点击确认，其他用户点击无效
steps{
	input(message:'请确认测试已经通过'
	id:'idfortestpass',ok:'我确认',
	submitter:'BossID',submitterParameter:'versionStr')
}
样例2：确认时还需输入参数信息：选择发布类型，之后把参数打印出来或者传给其他步骤
steps{
	script{
	env.RELEASE_SCOPE = input message:'请选择发布类型：',
	ok:'Release!',
	parameters:[choice(name:'RELEASE_SCOPE',
	choices:'开发环境\n测试环境\n生产环境',
	description:'请选择此次发布的类型。')]
	}
}

}

#异常处理

#stash——缓存，一般用于暂存<10M的文件
{
样例:缓存testport目录下的所有html文件到命名为report的stash下
stash include:'**/testport/*.html',name:'report'
unstash 'report'
}

}