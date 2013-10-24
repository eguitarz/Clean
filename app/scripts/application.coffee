@Clean.IndexRoute = Ember.Route.extend {}

@Clean.ApplicationRoute = Ember.Route.extend {}

@Clean.ApplicationView = Ember.View.extend
  classNames: ['appl-view']

Ember.TEMPLATES.application = Ember.Handlebars.compile '
  <div>ko ni chi wa</div>
'