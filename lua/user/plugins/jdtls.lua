local M = {}

function M.config()
  -- do nothing
  -- see https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
end

function M.setup()
  local status_ok, jdtls = pcall(require, 'jdtls')
  if not status_ok then
    vim.notify('jdtls 没有加载或者未安装')
    return
  end
  local env = {
    HOME = os.getenv('HOME'),
    JAVA_HOME = os.getenv('JAVA_HOME'),
    JDTLS_RUN_JAVA = os.getenv('JDTLS_RUN_JAVA'),
    JDTLS_HOME = os.getenv('JDTLS_HOME'),
    JDTLS_WORKSPACE = os.getenv('JDTLS_WORKSPACE'),
    LOMBOK_JAR = os.getenv('LOMBOK_JAR'),
    MAVEN_HOME = os.getenv('MAVEN_HOME'),
  }

  local executionEnvironment = {
    J2SE_1_5 = 'J2SE-1.5',
    JavaSE_1_6 = 'JavaSE-1.6',
    JavaSE_1_7 = 'JavaSE-1.7',
    JavaSE_1_8 = 'JavaSE-1.8',
    JavaSE_9 = 'JavaSE-9',
    JavaSE_10 = 'JavaSE-10',
    JavaSE_11 = 'JavaSE-11',
    JavaSE_12 = 'JavaSE-12',
    JavaSE_13 = 'JavaSE-13',
    JavaSE_14 = 'JavaSE-14',
    JavaSE_15 = 'JavaSE-15',
    JavaSE_16 = 'JavaSE-16',
    JavaSE_17 = 'JavaSE-17',
    JavaSE_18 = 'JavaSE-18',
    JAVASE_19 = 'JavaSE-19',
  }

  local funcutil = require('user.core.funcutil')

  local osType = function()
    if funcutil.is_win then
      return 'config_win'
    elseif funcutil.is_mac then
      return 'config_mac'
    else
      return 'config_linux'
    end
  end

  local getJava = function()
    return funcutil.or_default(env.JDTLS_RUN_JAVA, env.JAVA_HOME .. '/bin/java')
  end

  local getJavaVerHome = function(v, dv)
    return os.getenv('JAVA_HOME' .. v) or dv
  end

  local getLombokJar = function()
    return funcutil.or_default(env.LOMBOK_JAR, '/home/devenvironment/Jdtls/lombok.jar')
  end

  local runtimes = function()
    local result = {}
    for _, value in pairs(executionEnvironment) do
      -- 获取版本
      local version = vim.fn.split(value, '-')[2]
      -- 判断是否是 1.8 之前的版本
      if string.match(version, '%.') then
        version = vim.split(version, '%.')[2]
      end
      -- 获取指定版本的 javaHome
      local javaHome = getJavaVerHome(version)
      local defaultJdk = false
      -- 如果指定版本的 javaHome 存在
      if javaHome then
        -- 获取源码
        local javaSources = vim.fn.glob(javaHome .. '/src.zip') or vim.fn.glob(javaHome .. '/lib/src.zip')
        -- 如果是 jdk 17 则设置为默认
        if executionEnvironment.JavaSE_17 == value then
          defaultJdk = true
        end
        table.insert(result, {
          name = value,
          path = javaHome,
          sources = javaSources,
          default = defaultJdk,
        })
      end
    end
    if #result == 0 then
      vim.notify('请设置 java 的环境变量 (JAVA_HOME, JAVA_HOME17...)')
    end
    return result
  end

  local jdtlsLauncher = vim.fn.glob(env.JDTLS_HOME .. 'plugins/org.eclipse.equinox.launcher_*.jar')
  local jdtlsConfig = vim.fn.glob(env.JDTLS_HOME .. osType())
  local projectName = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
  local workspaceDir = '/home/developcode/Java/' .. projectName
  local mavenSetting = env.MAVEN_HOME .. '/conf/settings.xml'

  local config = {
    cmd = {
      getJava(),
      '-Declipse.application=org.eclipse.jdt.ls.core.id1',
      '-Dosgi.bundles.defaultStartLevel=4',
      '-Declipse.product=org.eclipse.jdt.ls.core.product',
      '-Dlog.protocol=true',
      '-Dlog.level=ALL',
      '-Dsun.zip.disableMemoryMapping=true',
      '-Xms128m',
      '-XX:+UseG1GC',
      '-Xmx1024m',
      '-javaagent:' .. getLombokJar(),
      '--add-modules=ALL-SYSTEM',
      '--add-opens',
      'java.base/java.util=ALL-UNNAMED',
      '--add-opens',
      'java.base/java.lang=ALL-UNNAMED',
      '-jar',
      jdtlsLauncher,
      '-configuration',
      jdtlsConfig,
      '-data',
      workspaceDir,
    },

    filetypes = { 'java' },

    root_dir = require('jdtls.setup').find_root { '.git', 'mvnw', 'gradlew' },
    settings = {
      java = {
        -- 最大并发构建数
        maxConcurrentBuilds = 8,
        home = env.JAVA_HOME,
        project = {
          encoding = 'UTF-8',
          -- 资源过滤器
          resourceFilters = {
            'node_modules',
            '.git',
            '.idea',
          },
        },
        import = {
          -- 排除列表
          exclusions = {
            '**/node_modules/**',
            '**/.metadata/**',
            '**/archetype-resources/**',
            '**/META-INF/maven/**',
            '**/.git/**',
            '**/.idea/**',
          },
        },
        referenceCodeLens = { enabled = true },
        implementationsCodeLens = { enabled = true },
        templates = {
          fileHeader = {
            '/**',
            ' * @author : ${user}',
            ' * @version 1.0',
            ' * @date : ${date|${time}',
            ' * @className : ${name}',
            ' * @description : TODO(一句话描述该类的功能)',
            ' */',
          },
        },
        eclipse = {
          downloadSources = true,
        },
        server = {
          launchMode = 'Hybrid',
        },
        maven = {
          downloadSources = true,
          updateSnapshots = true,
        },
        signatureHelp = {
          enabled = true,
          description = {
            enabled = true,
          },
        },
        contentProvider = { preferred = 'fernflower' },
        completion = {
          favoriteStaticMembers = {
            'org.junit.Assert.*',
            'org.junit.Assert.*',
            'org.junit.Assume.*',
            'org.junit.jupiter.api.Assertions.*',
            'org.junit.jupiter.api.Assumptions.*',
            'org.junit.jupiter.api.DynamicContainer.*',
            'org.junit.jupiter.api.DynamicTest.*',
            'org.hamcrest.MatcherAssert.assertThat',
            'org.hamcrest.Matchers.*',
            'org.hamcrest.CoreMatchers.*',
            'java.util.Objects.requireNonNull',
            'java.util.Objects.requireNonNullElse',
            'org.mockito.Mockito.*',
          },
          filteredTypes = {
            'com.sun.*',
            'io.micrometer.shaded.*',
            'java.awt.*',
            'org.graalvm.*',
            'jdk.*',
            'sun.*',
          },
        },
        sources = {
          organizeImports = {
            starThreshold = 9999,
            staticStarThreshold = 9999,
          },
        },
        configuration = {
          maven = {
            userSettings = mavenSetting,
            globalSettings = mavenSetting,
          },
          runtimes = runtimes(),
        },
      },
    },
  }

  jdtls.start_or_attach(config)
end

return M
