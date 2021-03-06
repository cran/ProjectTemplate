context('Create project')

expect_file <- function(...) {
  x <- file.path(...)
  expect_true(file.exists(x), x)
}

expect_no_file <- function(...) {
  x <- file.path(...)
  expect_false(file.exists(x), x)
}

expect_dir <- function(...) {
  x <- file.path(...)
  expect_file(x)
  expect_true(.is.dir(x))
  expect_file(file.path(x, 'README.md'))
}

expect_full <- function() {
  expect_dir('.')
  expect_dir('cache')
  expect_dir('config')
  expect_file(file.path('config', 'global.dcf'))
  expect_dir('data')
  expect_dir('diagnostics')
  expect_file(file.path('diagnostics', '1.R'))
  expect_dir('docs')
  expect_dir('graphs')
  expect_dir('lib')
  expect_file(file.path('lib', 'helpers.R'))
  expect_dir('logs')
  expect_dir('munge')
  expect_file(file.path('munge', '01-A.R'))
  expect_dir('profiling')
  expect_file(file.path('profiling', '1.R'))
  expect_dir('reports')
  expect_dir('src')
  expect_file(file.path('src', 'eda.R'))
  expect_dir('tests')
  expect_file(file.path('tests', '1.R'))
  expect_file(file.path('TODO'))
}

expect_minimal <- function() {
  expect_dir('.')
  expect_dir('cache')
  expect_dir('config')
  expect_file(file.path('config', 'global.dcf'))
  expect_dir('data')
  expect_dir('munge')
  expect_file(file.path('munge', '01-A.R'))
  expect_dir('src')
  expect_file(file.path('src', 'eda.R'))

  expect_no_file('diagnostics')
  expect_no_file('docs')
  expect_no_file('graphs')
  expect_no_file('lib')
  expect_no_file('logs')
  expect_no_file('profiling')
  expect_no_file('reports')
  expect_no_file('tests')
  expect_no_file('TODO')
}

test_that('Full project', {

  test_project <- tempfile('test_project')
  suppressMessages(create.project(test_project, template = 'full'))
  on.exit(unlink(test_project, recursive = TRUE), add = TRUE)

  oldwd <- setwd(test_project)
  on.exit(setwd(oldwd), add = TRUE)

  expect_full()

  suppressMessages(load.project())
  suppressMessages(test.project())

})

test_that('Miminal project', {

  test_project <- tempfile('test_project')
  suppressMessages(create.project(test_project, template = 'minimal'))
  on.exit(unlink(test_project, recursive = TRUE), add = TRUE)

  oldwd <- setwd(test_project)
  on.exit(setwd(oldwd), add = TRUE)

  expect_minimal()

  suppressMessages(load.project())

})

test_that('Test full project into existing directory', {

  test_project <- tempfile('test_project')
  expect_false(file.exists(file.path(test_project)))
  dir.create(test_project)
  on.exit(unlink(test_project, recursive = TRUE), add = TRUE)
  expect_true(file.exists(file.path(test_project)))

  suppressMessages(create.project(test_project, template = 'full'))

  oldwd <- setwd(test_project)
  on.exit(setwd(oldwd), add = TRUE)

  expect_full()

  suppressMessages(load.project())
  suppressMessages(test.project())

})

test_that('Test minimal project into existing directory with an unrelated entry', {

  test_project <- tempfile('test_project')
  expect_false(file.exists(file.path(test_project)))
  dir.create(test_project)
  on.exit(unlink(test_project, recursive = TRUE), add = TRUE)
  expect_true(file.exists(file.path(test_project)))

  suppressMessages(create.project(test_project, template = 'minimal', merge.strategy = "allow.non.conflict"))

  oldwd <- setwd(test_project)
  on.exit(setwd(oldwd), add = TRUE)

  expect_minimal()

  suppressMessages(load.project())

})

test_that('Test failure creating project into existing directory with an unrelated entry if merge.existing is not set', {

  test_project <- tempfile('test_project')
  expect_false(file.exists(file.path(test_project)))
  dir.create(test_project)
  on.exit(unlink(test_project, recursive = TRUE), add = TRUE)
  expect_true(file.exists(file.path(test_project)))

  file.create(file.path(test_project, '.dummy'))
  expect_true(file.exists(file.path(test_project, '.dummy')))
  dir.create(file.path(test_project, 'dummy_dir'))
  expect_true(file.exists(file.path(test_project, 'dummy_dir')))

  expect_error(
    suppressMessages(
      create.project(test_project, template = 'minimal'), "not empty"))

})

test_that('Test failure creating project in directory with existing empty directory matching the name of a template directory', {

  test_project <- tempfile('test_project')
  expect_false(file.exists(file.path(test_project)))
  dir.create(test_project)
  on.exit(unlink(test_project, recursive = TRUE), add = TRUE)
  expect_true(file.exists(file.path(test_project)))

  dir.create(file.path(test_project, 'munge'))
  expect_true(file.exists(file.path(test_project, 'munge')))

  expect_error(
    suppressMessages(
      create.project(test_project, template = 'minimal',
                     merge.strategy = "allow.non.conflict"), "overwrite"))

})

test_that('Test failure creating project in directory with existing file matching the name of a template directory',{

  test_project <- tempfile('test_project')
  expect_false(file.exists(file.path(test_project)))
  dir.create(test_project)
  on.exit(unlink(test_project, recursive = TRUE), add = TRUE)
  expect_true(file.exists(file.path(test_project)))

  file.create(file.path(test_project, 'munge'))
  expect_true(file.exists(file.path(test_project, 'munge')))

  expect_error(
    suppressMessages(
      create.project(test_project, template = 'minimal',
                     merge.strategy = "allow.non.conflict"), "overwrite"))

})

test_that('Test failure creating project in directory with existing empty directory matching the name of a template file', {

  test_project <- tempfile('test_project')
  expect_false(file.exists(file.path(test_project)))
  dir.create(test_project)
  on.exit(unlink(test_project, recursive = TRUE), add = TRUE)
  expect_true(file.exists(file.path(test_project)))

  dir.create(file.path(test_project, 'README.md'))
  expect_true(file.exists(file.path(test_project, 'README.md')))

  expect_error(
    suppressMessages(
      create.project(test_project, template = 'minimal',
                     merge.strategy = "allow.non.conflict"), "overwrite"))


})

test_that('Test failure creating project in directory with existing file matching the name of a template file', {

  test_project <- tempfile('test_project')
  expect_false(file.exists(file.path(test_project)))
  dir.create(test_project)
  on.exit(unlink(test_project, recursive = TRUE), add = TRUE)
  expect_true(file.exists(file.path(test_project)))

  file.create(file.path(test_project, 'README.md'))
  expect_true(file.exists(file.path(test_project, 'README.md')))

  expect_error(
    suppressMessages(
      create.project(test_project, template = 'minimal',
                     merge.strategy = "allow.non.conflict"), "overwrite"))

})

test_that('Dont create projects inside other projects', {
        test_project <- tempfile('test_project')
        suppressMessages(create.project(test_project, template = 'full'))
        on.exit(unlink(test_project, recursive = TRUE), add = TRUE)

        oldwd <- setwd(test_project)
        on.exit(setwd(oldwd), add = TRUE)

        # shouldn't be able to create a new project inside this one
        expect_error(create.project("new_project"))

        # Also shouldn't be able to create one inside a sub directory of an existing project
        setwd(file.path(test_project, 'lib'))
        expect_error(create.project("new_project"))
})

test_that('Do create projects on an absolute path from inside project', {
  test_project <- tempfile('test_project')
  test_project2 <- tempfile('test_project2')
  suppressMessages(create.project(test_project, template = 'full'))
  on.exit(unlink(test_project, recursive = TRUE), add = TRUE)

  oldwd <- setwd(test_project)
  on.exit(setwd(oldwd), add = TRUE)

  # should be able to create a new project outside this one
  expect_error(create.project(test_project2), NA)
  on.exit(unlink(test_project2, recursive = TRUE), add = TRUE)

  # But you shouldn't be able to create one inside a sub directory of an
  # existing project, even on an absolute path outside the current project
  setwd(file.path(test_project, 'lib'))
  expect_error(create.project(file.path(test_project2, "munge")))
})
