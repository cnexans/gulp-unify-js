gulp = require 'gulp'
coffee = require 'gulp-coffee'
gutil = require 'gulp-util'
plumber = require 'gulp-plumber'
ts = require 'gulp-typescript'
deamdify = require './'
optimizer = require 'gulp-amd-optimizer'

handler = (error) ->
  gutil.log(
    (gutil.colors.inverse error.name), 'found during compilation',
    'Check', error.filename,
    'on line', error.location.first_line
  )
  this.emit 'end'


gulp.task 'default', ['build', 'watch']

gulp.task 'build', () ->
  return gulp.src 'src/*.coffee'
    .pipe plumber handler
    .pipe coffee bare:true
    .pipe gulp.dest '.'

gulp.task 'watch', () ->
  return gulp.watch 'src/*.coffee', ['build']

gulp.task 'test', ['test:js', 'test:ts']

gulp.task 'test:js', () ->
  return gulp.src 'test/fixtures/with-defines/*.js'
    .pipe optimizer {baseUrl: '/'}
    .pipe deamdify outputs:'defines-from-javascript.js'
    .pipe gulp.dest 'test/compiled'

gulp.task 'test:ts', () ->
    return gulp.src 'test/fixtures/typescript/**/*.ts'
        .pipe ts
            "module": "amd",
            "target": "es5",
            "noImplicitAny": false,
            "sourceMap": false,
            "removeComments" : true,
            "outFile" : 'compiled.js'
        .pipe deamdify outputs:'from-typescript.js'
        .pipe gulp.dest 'test/compiled'
