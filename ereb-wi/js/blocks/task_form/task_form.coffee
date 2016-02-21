class TaskForm

  constructor: (wrapper) ->
    @wrapper = wrapper
    monkberry.mount(require('./task_form.monk'))
    @template = monkberry.render('task_form')
    @initEvents()

  render: (@taskId) ->
    @fetch @taskId, (data) =>
      @data = data
      @template.appendTo(@wrapper)
      @template.update @data
      @initCodeMirror() unless @codeMirror

  initCodeMirror: ->
    textarea = document.getElementById('shell_script')
    if textarea
      @codeMirror = CodeMirror.fromTextArea(textarea, {
        mode: 'shell'
        theme: '3024-night'
        readOnly: "nocursor"
      })

  initEvents: () ->
    @template.on 'submit', '#task_form', (e) =>
      e.preventDefault()
      data =
        cron_schedule: $('#cron_schedule').val()
        cmd: $('#cmd').val()
        description: $('#description').val()
      @updateTask @taskId, data, (update_status) =>
        @data.notification =
          success: update_status == true
        @template.update @data
        delete @data.notification

    @template.on 'click', '#task_form__delete', (e) =>
      e.preventDefault()
      @deleteTask @taskId, =>
        document.location.hash = '#/task_list'

    @template.on 'click', '#task_form__manual_run', (e) =>
      e.preventDefault()
      @runTask @taskId, =>
        @render(@taskId)

    @template.on 'click', '#task_form__enabled_button', (e) =>
      e.preventDefault()
      data =
        enabled: ! ( $('#enabled').val() == 'true' ) # toggle enabled state
      @updateTask @taskId, data, =>
        @render(@taskId)

    @template.on 'change', '#cron_schedule', (e) =>
      @data.config.cron_schedule = $('#cron_schedule').val()
      @template.update @data

  updateTask: (taskId, data, callback) ->
    url = [window.SERVER_HOST, 'tasks', taskId].join('/')
    promise = $.post url, JSON.stringify(data)
    promise.done (response) => callback(true)
    promise.fail (response) => callback(false)

  deleteTask: (taskId, callback) ->
    url = [window.SERVER_HOST, 'tasks', taskId].join('/')
    promise = $.ajax
      url: url
      method: 'DELETE'

    promise.done (response) =>
      callback()

  runTask: (taskId, callback) ->
    url = [window.SERVER_HOST, 'tasks', taskId, 'run'].join('/')
    promise = $.ajax
      url: url

    promise.done (response) =>
      callback()

  fetch: (taskId, callback, useStub=false) ->
    if useStub
      stub = require('./stub.coffee')
      callback(stub)
    else
      url = [window.SERVER_HOST, 'tasks', taskId].join('/')
      promise = $.get url

      promise.done (response) ->

        callback JSON.parse(response)

      promise.fail (response) ->
        callback []



module.exports = TaskForm
