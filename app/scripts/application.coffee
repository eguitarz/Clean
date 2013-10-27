@Clean.IndexRoute = Ember.Route.extend {}

@Clean.ApplicationRoute = Ember.Route.extend {}

@Clean.ApplicationView = Ember.View.extend
  classNames: ['appl-view']
  didInsertElement: =>
  	@Clean.editor.init()

Ember.TEMPLATES.application = Ember.Handlebars.compile '
  <header>Clean Editor</header>
  <div id="status-bar">
      <div class="debug-status ctrl hidden">ctrl</div>
      <div class="debug-status alt hidden">alt</div>
      <div class="debug-status shift hidden">shift</div>
      <div class="debug-status cmd hidden">cmd</div>
      <div id="debug-keyup"></div>
      <div id="debug-keydown"></div>
  </div>
  <div id="editor-title" contentEditable="true"></div>
  <div class="content">
      <div class="flex-container">
          <div id="editor" contentEditable="true"></div>
          <div id="debug"></div>
      </div>
      <div id="tooltip" class="hidden">
        <ul class="left-panel">
          <li>H1</li>
          <li>H2</li>
          <li>Q</li>
        </ul>
        <ul class="right-panel">
          <li>+ Append image</li>
        </ul>
      </div>
  </div>
  <ul id="toolpad"><li>link</li></ul>
'