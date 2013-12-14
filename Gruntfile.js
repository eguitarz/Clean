'use strict';
var lrSnippet = require('grunt-contrib-livereload/lib/utils').livereloadSnippet;
var mountFolder = function (connect, dir) {
    return connect.static(require('path').resolve(dir));
};

// # Globbing
// for performance reasons we're only matching one level down:
// 'test/spec/{,*/}*.js'
// use this if you want to match all subfolders:
// 'test/spec/**/*.js'

module.exports = function (grunt) {
  // load all grunt tasks
  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks);

  // configurable paths
  var cleaneditorConfig = {
      app: 'app',
      dist: 'dist',
      dev: '.dev'
  };

  grunt.initConfig({
    cleaneditor: cleaneditorConfig,
    watch: {
      coffee: {
        files: ['<%= cleaneditor.app %>/scripts/{,*/}*.coffee'],
        tasks: ['coffee:dist', 'copy']
      },
      coffeeTest: {
        files: ['test/spec/{,*/}*.coffee'],
        tasks: ['coffee:test']
      },
      compass: {
        files: ['<%= cleaneditor.app %>/styles/{,*/}*.{scss,sass}'],
        tasks: ['compass:dist', 'copy']
      },
      statics: {
        files: ['<%= cleaneditor.app %>/*.html', '{.tmp,<%= cleaneditor.app %>}/styles/{,*/}*.css', '{.tmp,<%= cleaneditor.app %>}/scripts/{,*/}*.js', '{.tmp,<%= cleaneditor.app %>}/vendor/{,*/}*.js'],
        tasks: ['copy']
      },
      livereload: {
        files: [
            '<%= cleaneditor.app %>/*.html',
            '{.tmp,<%= cleaneditor.app %>}/styles/{,*/}*.css',
            '{.tmp,<%= cleaneditor.app %>}/scripts/{,*/}*.js',
            '<%= cleaneditor.app %>/images/{,*/}*.{png,jpg,jpeg,webp}'
        ],
        tasks: ['livereload']
      }
    },
    connect: {
      options: {
        port: 4000,
        // change this to '0.0.0.0' to access the server from outside
        hostname: '0.0.0.0'
      },
      livereload: {
        options: {
          middleware: function (connect) {
            return [
                // lrSnippet,
                mountFolder(connect, '.tmp'),
                mountFolder(connect, 'app')
            ];
          }
        }
      },
      test: {
        options: {
          middleware: function (connect) {
            return [
                mountFolder(connect, '.tmp'),
                mountFolder(connect, 'test')
            ];
          }
        }
      },
      dist: {
        options: {
          middleware: function (connect) {
            return [
                mountFolder(connect, 'dist')
            ];
          }
        }
      }
    },
    open: {
        server: {
            path: 'http://localhost:<%= connect.options.port %>'
        }
    },
    clean: {
        dist: ['.tmp', '<%= cleaneditor.dist %>/*'],
        server: '.tmp',
        dev: '.dev'
    },
    jshint: {
      options: {
          jshintrc: '.jshintrc'
      },
      all: [
          'Gruntfile.js',
          '<%= cleaneditor.app %>/scripts/{,*/}*.js',
          '!<%= cleaneditor.app %>/vendor/*',
          'test/spec/{,*/}*.js'
      ]
    },
    mocha: {
      all: {
        options: {
            run: true,
            urls: ['http://localhost:<%= connect.options.port %>/index.html']
        }
      }
    },
    coffee: {
      dist: {
        files: [{
          // rather than compiling multiple files here you should
          // require them into your main .coffee file
          expand: true,
          cwd: '<%= cleaneditor.app %>/scripts',
          src: '*.coffee',
          dest: '.tmp/scripts',
          ext: '.js'
        }]
      },
      test: {
        files: [{
          expand: true,
          cwd: '.tmp/spec',
          src: '*.coffee',
          dest: 'test/spec'
        }]
      }
    },
    compass: {
      options: {
        sassDir: '<%= cleaneditor.app %>/styles/',
        cssDir: '.tmp/styles',
        importPath: '<%= cleaneditor.app %>/styles/modules',
        imagesDir: '<%= cleaneditor.app %>/images',
        javascriptsDir: '<%= cleaneditor.app %>/scripts',
        fontsDir: '<%= cleaneditor.app %>/styles/fonts',
        // importPath: '<%= cleaneditor.app %>/components',
        relativeAssets: true
      },
      dist: {
        options: {
            debugInfo: true
        }
      },
      server: {
        options: {
            debugInfo: true
        }
      }
    },
    uglify: {
      dist: {
        files: {
          '<%= cleaneditor.dist %>/scripts/cleaneditor.js': [
              '<%= cleaneditor.app %>/vendor/jquery-1.9.1.js',
              '<%= cleaneditor.app %>/vendor/jquery-ui-widget.js',
              '<%= cleaneditor.app %>/vendor/store.js',
              '<%= cleaneditor.app %>/vendor/autosize.jquery.js',
              '<%= cleaneditor.app %>/vendor/jquery.fileupload.js',
              '<%= cleaneditor.app %>/vendor/handlebars-1.0.0.js',
              '<%= cleaneditor.app %>/vendor/ember.1.0.0.js',
              '<%= cleaneditor.app %>/vendor/simple-select.js',
              '<%= cleaneditor.app %>/vendor/rangy-core.js',
              '<%= cleaneditor.app %>/vendor/rangy-cssclassapplier.js',
              '<%= cleaneditor.app %>/vendor/rangy-selectionsaverestore.js',
              '.tmp/scripts/tools.js',
              '.tmp/scripts/main.js',
              '.tmp/scripts/tools.js',
              '.tmp/scripts/editorManager.js',
              '.tmp/scripts/plugins.js',
              '.tmp/scripts/main.js',
              '.tmp/scripts/routes.js',
              '.tmp/scripts/application.js',
              '.tmp/scripts/dashboard.js',
              '.tmp/scripts/drafts.js',
              '.tmp/scripts/dialog.js',
              '.tmp/scripts/posts.js',
              '.tmp/scripts/posts_new.js',
              '.tmp/scripts/posts_read.js',
              '.tmp/scripts/posts_edit.js',
              '.tmp/scripts/posts_delete.js',
              '.tmp/scripts/summary.js'
              // '<%= cleaneditor.app %>/scripts/{,*/}*.js',
              // '.tmp/scripts/{,*/}*.js'
          ],
        }
      }
    },
    useminPrepare: {
      html: '<%= cleaneditor.app %>/index.html',
      options: {
        dest: '<%= cleaneditor.dist %>'
      }
    },
    usemin: {
      html: ['<%= cleaneditor.dist %>/{,*/}*.html'],
      css: ['<%= cleaneditor.dist %>/styles/{,*/}*.css'],
      options: {
          dirs: ['<%= cleaneditor.dist %>']
      }
    },
    imagemin: {
      dist: {
        files: [{
          expand: true,
          cwd: '<%= cleaneditor.app %>/images',
          src: '{,*/}*.{png,jpg,jpeg}',
          dest: '<%= cleaneditor.dist %>/images'
        }]
      }
    },
    cssmin: {
      dist: {
        files: {
          '<%= cleaneditor.dist %>/styles/cleaneditor.css': [
            '<%= cleaneditor.app %>/styles/{,*/}*.css',
            '.tmp/styles/{,*/}*.css'
          ]
        }
      }
    },
    htmlmin: {
      dist: {
        options: {
          removeCommentsFromCDATA: true,
          // https://github.com/yeoman/grunt-usemin/issues/44
          //collapseWhitespace: true,
          collapseBooleanAttributes: true,
          // removeAttributeQuotes: true,
          removeRedundantAttributes: true,
          useShortDoctype: true,
          removeEmptyAttributes: true,
          // removeOptionalTags: true
        },
        files: [{
          expand: true,
          cwd: '<%= cleaneditor.app %>',
          src: '*.html',
          dest: '<%= cleaneditor.dist %>'
        }]
      }
    },
    copy: {
      dist: {
        files: [{
          expand: true,
          dot: true,
          cwd: '<%= cleaneditor.app %>',
          dest: '<%= cleaneditor.dist %>',
          src: [
            '*.{ico,txt,pdf}',
            '.htaccess'
          ]
        },
        {
          expand: true,
          dot: true,
          cwd: '<%= cleaneditor.app %>/images',
          dest: '<%= cleaneditor.dist %>/images',
          src: [
            '*.{png,gif,jpg}'
          ]
        },
        {
          expand: true,
          dot: true,
          cwd: '<%= cleaneditor.app %>/fonts',
          dest: '<%= cleaneditor.dist %>/fonts',
          src: [
            '*.{svg,eot,ttf,woff}'
          ]
        },
        // {
        //   expand: true,
        //   dot: true,
        //   cwd: '<%= cleaneditor.app %>/vendor',
        //   dest: '<%= cleaneditor.dist %>/vendor',
        //   src: [
        //     '*.js'
        //   ]
        // }
        ]
      },
      dev: {
        files: [{
          expand: true,
          dot: true,
          cwd: '<%= cleaneditor.app %>',
          dest: '<%= cleaneditor.dev %>',
          src: ['*.html', '*.ico']
        }, {
          expand: true,
          dot: true,
          cwd: '<%= cleaneditor.app %>/vendor',
          dest: '<%= cleaneditor.dev %>/vendor',
          src: ['*.js']
        },
        {
          expand: true,
          dot: true,
          cwd: '<%= cleaneditor.app %>/images',
          dest: '<%= cleaneditor.dev %>/images',
          src: [
            '*.{png,gif,jpg}'
          ]
        },
        {
          expand: true,
          dot: true,
          cwd: '<%= cleaneditor.app %>/fonts',
          dest: '<%= cleaneditor.dev %>/fonts',
          src: [
            '*.{svg,eot,ttf,woff}'
          ]
        },
        {
          expand: true,
          dot: true,
          cwd: '<%= cleaneditor.app %>/scripts',
          dest: '<%= cleaneditor.dev %>/scripts',
          src: ['*.js']
        },
        {
          expand: true,
          dot: true,
          cwd: '.tmp/scripts',
          dest: '<%= cleaneditor.dev %>/scripts',
          src: ['*.js']
        }, {
          expand: true,
          dot: true,
          cwd: '.tmp/styles',
          dest: '<%= cleaneditor.dev %>/styles',
          src: ['*.css']
        },
        {
          expand: true,
          dot: true,
          cwd: '<%= cleaneditor.app %>/styles',
          dest: '<%= cleaneditor.dev %>/styles',
          src: ['*.css']
        }]
      }
    },
    bower: {
      all: {
        rjsConfig: '<%= cleaneditor.app %>/scripts/main.js'
      }
    },
    rev: {
      files: {
        src: ['<%= cleaneditor.dist %>/{,*/}/*.js', '<%= cleaneditor.dist %>/styles/*.css']
      }
    }
  });

  grunt.renameTask('regarde', 'watch');

  grunt.registerTask('server', function (target) {
    if (target === 'dist') {
      return grunt.task.run(['build', 'open', 'connect:dist:keepalive']);
    }

    grunt.task.run([
      'clean:server',
      'coffee:dist',
      'compass:server',
      // 'livereload-start',
      'connect:livereload',
      // 'open',
      'watch'
    ]);
  });

  grunt.registerTask('test', [
    'clean:server',
    'coffee',
    'compass',
    'connect:test',
    'mocha'
  ]);

  grunt.registerTask('build', [
    'clean:dist',
    'coffee',
    'compass:dist',
    'useminPrepare',
    'imagemin',
    'htmlmin',
    'cssmin',
    'uglify',
    'copy',
    'rev',
    'usemin',
  ]);

  grunt.registerTask('dev', [
    'clean:dev',
    'coffee',
    'compass:dist',
    'copy',
    // 'livereload-start',
    'watch'
  ]);

  grunt.registerTask('default', [
    // 'jshint',
    // 'test',
    'dev'
  ]);
};
