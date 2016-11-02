

use ExtUtils::MakeMaker;

rename('README.md','README') if -f 'README.md';

WriteMakefile(
	NAME		=> 'App::video-bookmarks',
	AUTHOR		=> 'Clipland (clipland@cpan.org)',
	ABSTRACT_FROM	=> 'video-bookmarks',
	VERSION_FROM	=> 'video-bookmarks',
	LICENSE		=> 'gpl', # as close as it gets to GPL3+AL2
	PREREQ_PM	=> {
		"File::ExtAttr"	=> 0,
		"Encode"	=> 0,
		"Getopt::Long"	=> 0,
		"JSON::XS"	=> 0,
		"Path::Tiny"	=> 0,
		"Pod::Usage"	=> 0,
	},
# no tests
#	TEST_REQUIRES	=> {
#		'Test::More'		=> 0,
#	},
	EXE_FILES	=> [
		'video-bookmarks',
	],
	META_MERGE	=> {
		'meta-spec'	=> { version => 2 },
		resources	=> {
			repository => {
				type=> 'git',
				url => 'https://github.com/clipland/video-bookmarks.git',
				web => 'https://github.com/clipland/video-bookmarks',
			},
		},
	},
	dist => {
		POSTOP => 'perl -e "rename(\'README\',\'README.md\') if -f \'README\'"',
	},
	realclean => {
		POSTOP => 'perl -e "rename(\'README\',\'README.md\') if -f \'README\'"',
	},
	MIN_PERL_VERSION	=> 5.004, # nothing special in this dist, let's just make CPANTS happier
);
