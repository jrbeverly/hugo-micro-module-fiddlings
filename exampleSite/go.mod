module example.com/hmm/site

go 1.23

require (
	example.com/hmm/orchestrator v0.0.0
	example.com/hmm/theme v0.0.0
	example.com/hmm/masthead v0.0.0
	example.com/hmm/colophon v0.0.0
	example.com/hmm/logo v0.0.0
	example.com/hmm/nav v0.0.0
	example.com/hmm/locale v0.0.0
	example.com/hmm/social v0.0.0
	example.com/hmm/copyright v0.0.0
	example.com/hmm/composition v0.0.0
	example.com/hmm/analytics v0.0.0
)

replace (
	example.com/hmm/orchestrator => ../orchestrator
	example.com/hmm/theme => ../modules/theme
	example.com/hmm/masthead => ../modules/masthead
	example.com/hmm/colophon => ../modules/colophon
	example.com/hmm/logo => ../modules/logo
	example.com/hmm/nav => ../modules/nav
	example.com/hmm/locale => ../modules/locale
	example.com/hmm/social => ../modules/social
	example.com/hmm/copyright => ../modules/copyright
	example.com/hmm/composition => ../modules/composition
	example.com/hmm/analytics => ../modules/analytics
)
