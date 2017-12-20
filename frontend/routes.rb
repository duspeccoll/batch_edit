ArchivesSpace::Application.routes.draw do
  match('/plugins/batch_edit' => 'batch_edit#index', :via => [:get])
  match('/plugins/batch_edit/preview' => 'batch_edit#preview', :via => [:post])
end
