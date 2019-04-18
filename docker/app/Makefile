SHELL = /bin/bash


define newline


endef

EMIT = echo -e '$(subst $(newline),\n,$(1))'


define GDATE_C_PATCH
--- a/glib/glib/gdate.c
+++ b/glib/glib/gdate.c
@@ -2439,6 +2439,9 @@ win32_strftime_helper (const GDate     *d,
  *
  * Returns: number of characters written to the buffer, or 0 the buffer was too small
  */
+#pragma GCC diagnostic push
+#pragma GCC diagnostic ignored "-Wformat-nonliteral"
+
 gsize     
 g_date_strftime (gchar       *s, 
                  gsize        slen, 
@@ -2549,3 +2552,5 @@ g_date_strftime (gchar       *s,
   return retval;
 #endif
 }
+
+#pragma GCC diagnostic pop
endef


work/gdate.c.patch:
	mkdir -p work
	@$(call EMIT,$(GDATE_C_PATCH)) > $(@)

_esy: work/gdate.c.patch package.json
	esy install
	find /root/.esy -name "gdate.c" -exec patch -N '{}' work/gdate.c.patch ';'

.PHONY: clean-esy-build
clean-esy-build: 
	rm -rf _esy


_esy/default/build/default/bin/main.exe: _esy 
	esy

.PHONY: main.exe
main.exe: _esy/default/build/default/bin/main.exe

.PHONY: rebuild
rebuild: _esy
	esy

.PHONY: run
run: _esy/default/build/default/bin/main.exe
	./_esy/default/build/default/bin/main.exe

# Build and run main.exe
.PHONY: brun
brun: rebuild run
