ifneq ($(LOG),)
$(foreach X,$(LOG),$(eval RUN_FLAGS+=+LOG_$X))
endif

ifneq ($(NOLOG),)
	EXTRA_FLAGS+=-D NOLOG=1
endif

REBUILD_LIBRARIES+=Logging