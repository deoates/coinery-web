Template = require 'templates/new'
DropzoneTemplate = require 'templates/dropzone'

module.exports = class NewProductView extends Backbone.View

  el: '.content'

  events: ->
    'click a[data-href="back"]': 'backHandler'
    'click a[data-href="save"]': 'saveHandler'
    'click a[data-href="done"]': 'doneHandler'
    'keyup input.currency': 'currencyHandler'
    'keydown input.currency': 'currencyValidateHandler'
    'focus input': 'inputFocusHandler'

  initialize: (options) ->
    @user = options.user

  render: ->
    @$el.html Template {}
    do @postRender


  postRender: ->
    @$('input').focus()


  saveHandler: (e) ->
    do e.preventDefault

    $currentStep = $(e.target).closest('.fieldset')
    step = $currentStep.index()

    errors = 0

    $currentStep.find('[required]').each (i, el) ->
      $(el).removeClass 'error'
      if $(el).val() is ''
        $(el).addClass 'error'
        errors++

    unless errors > 0
      val = $currentStep.find('input').first().val()

      switch step
        when 1
          @model.setTitle val

        when 2
          @model.setPrice val.replace('$', '')

          @model.save {},
            async: false
            success: (response) =>
              do @dropzoneInit
            error: (xhr, status) ->
              console.log xhr, status


      $currentStep.addClass('complete')
                 .next().removeClass('hidden')
                 .find('input')?.first().focus()

    false

  inputFocusHandler: (e) ->
    $(e.target).closest('.fieldset').removeClass 'complete'

  currencyHandler: (e) ->

    return if e.keyCode is 190

    inputs =
      'btc': $('[data-currency="BTC"] input')
      'usd': $('[data-currency="USD"] input')

    focus = $(e.target).parent().attr 'data-currency'
    rate = window.conversion_rate
    if not rate
      rate = (1/540)

    raw = $(e.target).val().replace '$', ''
    amount = parseFloat(raw)

    if focus is 'BTC'
      usd = amount / rate
      unless isNaN(usd)
        inputs.usd.addClass 'changing'
        delay 150, ->
          inputs.usd.val "$#{usd.toFixed(2).toString()}"
        delay 300, ->
          inputs.usd.removeClass 'changing'

    if focus is 'USD'
      btc = amount * rate
      unless isNaN(btc)
        inputs.btc.addClass 'changing'
        delay 150, ->
          inputs.btc.val parseFloat(btc.toFixed(5))
        delay 300, ->
          inputs.btc.removeClass 'changing'

      unless isNaN(amount)
        inputs.usd.val "$#{amount.toString()}"


  dropzoneInit: ->

    # @override: update width of progress bar
    uploadprogress = (file, progress, bytesSent) ->

      ref = file.previewElement.querySelectorAll "[data-dz-uploadprogress]"
      width = "#{100 - parseInt(progress)}%"

      results = []
      i = 0

      while i < ref.length
        node = ref[i]
        results.push node.style.width = width
        i++

      results

    # @override: human readable file size
    filesize = (size) ->
      if size >= Math.pow(1024, 4) / 10
        size = size / (Math.pow(1024, 4) / 10)
        string = "TB"
      else if size >= Math.pow(1024, 3) / 10
        size = size / (Math.pow(1024, 3) / 10)
        string = "GB"
      else if size >= Math.pow(1024, 2) / 10
        size = size / (Math.pow(1024, 2) / 10)
        string = "MB"
      else if size >= 1024 / 10
        size = size / (1024 / 10)
        string = "KB"
      else
        size = size * 10
        string = "b"

      "<strong>#{Math.round(size)/10}</strong>#{string}"


    # apply overrides to dropzone obj
    Dropzone::defaultOptions.uploadprogress = uploadprogress
    Dropzone::filesize = filesize

    # init dropzone with custom template
    @dropzone = new Dropzone 'a[data-href="dropzone"]',
      paramName: 'asset'
      previewsContainer: '.dz-preview-container'
      previewTemplate: DropzoneTemplate {}
      url: "#"

    url = => "#{window.api_root}/products/#{@model.get('id')}/assets"
    @dropzone.options.url = url()


    # update percentage count
    @dropzone.on 'uploadprogress', (file, progress, bytesSent) ->
      $('.dz-progress-percent').text Math.round(progress-1) + "%"

    # believe it or not this breaks without the console.log
    @dropzone.on 'addedFile', (file) ->
      console.log file

    @dropzone.on 'success', (file) =>
      do @updateFileCTA

  updateFileCTA: ->
    @$('a[data-href="dropzone"]').removeClass('button').html 'Upload Another File'
    @$('span.or').fadeIn()
    @$('a[data-href="done"]').fadeIn()


  doneHandler: (e) ->
    do e.preventDefault
    @collection.add(@model)
    @model.save {'status': 1},
      url: "#{window.api_root}/products/#{@model.id}"
      success: =>
        Backbone.history.navigate "products/edit/#{@model.id}", {trigger: true}
        console.log @model

  backHandler: ->
    Backbone.history.navigate "products", {trigger: true}





