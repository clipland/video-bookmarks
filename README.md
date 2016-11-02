Video-Bookmarks
===============

Proposed player independent standard for attaching textual metadata to certain
timecode positions within a video file, as markers, as annotations or as video
bookmarks. Version 1.

## DESCRIPTION

Some video-players or video editing software implement the notion of having a
marker at various time offsets of a video file.

A marker specifies a singular timecode position within a video-file. Mostly
a marker is indicator of the beginning of a section within a presentation, so
most markers are used to attach short textual notes to a video. Within the scope
of this document, these annotations are further meant to tell player software to
begin playback at these positions within a file, once a user specifies a
selected marker. As means to jump to a certain position of a presentation, we
regard these markers as video bookmarks, although they may be used in different
contexts than playback and for different purposes. As the overall idea can also
be applied to audio files, we might just as well speak of audio, or more
general, media bookmarks.

This document defines a syntax for describing these video bookmarks and offers
recommendations for storage of video bookmarks along with and embedded in files.

## SYNTAX & DATA STRUCTURES

We store two values per bookmark:

- The timecode offset in the form HH:MM:SS.mmm, whereas timecode 00:00 is the
  absolute beginning of the video-file, and not relative to potentially embedded
  timecode within the file. (H is hours, M minutes, S seconds, m milliseconds.)

- A descriptive text, free form. Which can be used for a description, a track
  title, notes, annotations, enumerations, etc.

The format further proposes optional metadata beyond the basics above, although
a specific syntax has not yet settled for these optional values:

- A type indicator, which can be used to tell implementing players how playback
  should be organized, played as "one-shot" (default, when omitted), or looped,
  or something like "seek" to indicate the player to seek to the specified
  position then pause. But beyond the use for playback, the type can be used by
  applications to attach application specific modes or arguments to markers.

- A second timecode position, an end position, which can be used to define a
  time span within the file.

Implementing applications should look into multiple storage layers, gather found
bookmarks and present them to the user for selection in order, sorted by
ascending timecode.

Storage layers are the filename (the file's basename), filesystem extended
attributes (xattr) and the video container's metadata key/value store (if
available). Bookmarks may be stored in all three stores, with deduplication done
by implementing applications. If video bookmarks are saved in a file's name and
the host filesystem doesn't allow the colon (":") character in filenames, the
colon may be exchanged with the dot (".").

We store these values into a metadata attribute with the name (key)
_video.bookmarks_ as a JSON encoded array of arrays. Or into _video.bookmarks_
plus the child keys _video.bookmark.1_ ... _video.bookmark.n_, in case the
underlying storage mechanism can't hold the length of the entire data structure.

Bookmarks can either be stored in the proposed Video-Bookmarks textual syntax
proposed here or as an array of arrays, encoded as JSON, with a list item layout
resembling the textual syntax.

### Timecode format

Both variants, syntax and JSON layout structure, share a common notation of
timecode values. Video bookmark's timecode format follows common understanding,
that means, it's evaluated backwards. Having a timecode of _0:22_ means 22
seconds, zero minutes - having a timecode of _1:22:00_ means one hour, 22
minutes and zero seconds, with the leading zero being omitted in the hours
position.

When only a number is given, like _123_, it is interpreted as seconds. This
follows a convention established by ffmpeg / avconv and is contrary to the
stated paradigm of evaluating timecode backwards (where it would mean it's a
millisecond value, with all leading hours, minutes, seconds omitted). The
briefest form of defining a millisecond offset following this scheme would be
_0.123_.

Timecode is not frame-rate dependent, nor does the last string element refer to
a specific frame. All numbers refer to absolute runtime at intended playback
speed.

### Textual syntax in filenames

The textual syntax for bookmarks in video files is mainly targeted at use in a
file's name, its basename. It looks similar to links in the Markdown markup
language but Video-Bookmarks have the URI and text positions exchanged. Here the
timecode is in square brackets, with the description in round brackets
(parentheses):

&nbsp; &nbsp; \[\<link\>](\<description>)

&nbsp; &nbsp; for example:<br>
&nbsp; &nbsp; \[01:22:45](here starts some moment in the video\)

&nbsp; &nbsp; embedded into a filename:<br>
&nbsp; &nbsp; /path/to/video/Videofile_123_xyz_\[01:22:45](here starts some moment in the video).mp4

An empty description must be defined as an empty string (or as JSON undef, see
below). Bookmarks set in filenames must consist of two square and two round 
brackets, even when the description is empty. So _\[00:58:14]()_ is a valid
video bookmark / marker.

For readability, markers in filenames should be separated from other filename
elements by either a space or a dash.

### JSON structure in extended attributes

The proposed standard requires video bookmarks to be stored in defined extended
attribute (xattr) keys. The idea behind this requirement and the storage
structure is to minimise I/O lookups. A single test for one extended attribute
(video.bookmarks) returns if video-bookmarks are present in xattr.

Video bookmarks stored in xattr require the metadata key _video.bookmarks_ to be
set. The value of _video.bookmarks_ is either a number, indicating
that there are n more _video.bookmark.n_ key/value attributes set, or a list of
arrays encoded as JSON.

The JSON data structure for video bookmarks is an array of arrays: each element
in the parent/main array is a reference to an array which represents one
bookmark. List positions in each bookmark array have implicit meaning: Position
one (array position 0) holds the timecode, position two (array position 1) is a
bookmark's description. Subsequent positions may hold values with a to-be
defined meaning in the future (compare "optional metadata beyond the basics"
above).

Example storage layouts:

&nbsp;&nbsp; video.bookmarks = \[00:00:05](this is a single bookmark in textual syntax)

&nbsp;&nbsp; video.bookmarks = \[["00:00:05", "this is a single bookmark in JSON syntax"]]

&nbsp;&nbsp; video.bookmarks  = 2<br>
&nbsp;&nbsp; video.bookmark.1 = \[["00:00:05", "this is bookmark one, in JSON syntax"],["00:00:12", "this is bookmark two"]]<br>
&nbsp;&nbsp; video.bookmark.2 = \[00:00:05](this is bookmark three, in textual syntax)

As the xattr storage structure allows to choose either the textual syntax or the
JSON layout, implementing software must test for these two variants.

### Storage in media container metadata-store

In case the container format of a media file allows to store arbitrary metadata
about a file, this store can be used to attach video bookmarks just as well.
Whether the textual syntax or the JSON structure layout is used depends on the
metadata store's characteristics in terms of abilities and size-restrictions.

## SEE ALSO / RELATED TECHNOLOGY

### Cue Sheets

Cue Sheets or .cue files are used to describe how individual tracks are laid out
in an otherwise monolithic audio file. Sometimes CD contents, after being
extracted from physical media, are stored as one continuous file with the
attached cue sheet containing the offsets of the individual tracks within the
file, similar to a playlist. Some audio containers, most notably FLAC, can embed
a whole or parts of a cue file, and supporting media players can treat such a
combination as individual tracks - although resulting sub-playlists end up being
problematic in relation with the predominant "one file = one playlist item"
paradigm.

### Chapters in media containers

Most modern media containers offer a facility to store or define information
about chapters in a file, similar to DVD or Blu-Ray presentations. And although
most players support chapters, very often users have no means to add chapters to
a file or edit defined chapters.

### Markers in WAV files

The RIFF file format, the data format of WAV files, allows to add cue chunks
to a file. These chunks can define named cue points for certain positions
in the audio file. Cue chunks are very often handled in audio software but are
limited to audio and wav files.

### Subtitles formats

Subtitle files define text to be displayed at specified timecodes of a video
file. As such, this technology solves similar problems in terms of attaching
metadata to certain time offsets within a video file. But from the established
use case and common implementations, using subtitle files to store different
metadata such as marks, annotations or bookmarks would lead to confusion.


## AUTHOR

Development of the _Video Bookmarks_ standards proposal and attached software
has been funded by Clipland GmbH, [clipland.com](http://www.clipland.com/)


## Copyright and License

This standards proposal is Copyright 2015-2017 Clipland GmbH. All rights reserved.

Clipland GmbH licenses this standard and its documentation to the public under
the GNU Free Documentation License (GNU FDL or GFDL) Version 1.3.
