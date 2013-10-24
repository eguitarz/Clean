@Clean.IndexRoute = Ember.Route.extend {}

@Clean.ApplicationRoute = Ember.Route.extend {}

@Clean.ApplicationView = Ember.View.extend
  classNames: ['appl-view']

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
      <div id="insertion" class=" hidden">
          <div class="expand-area">
              <div class="toolbar">
                  <div class="btn btn-image">Image</div>
                  <div class="link">
                      <input type="text" />
                      <div class="btn btn-cancel">X</div>
                  </div>
              </div>
          </div>
          <div class="btn btn-add">+</div>
      </div>
  </div>
'