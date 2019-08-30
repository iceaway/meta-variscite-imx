FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/:"

SRC_URI += " \
          file://init \
          file://pulseaudio-bluetooth.conf \
          file://system.pa \
          file://pulseaudio.service \
"

FILES_${PN} += "${sysconfdir}/systemd/system/*"

DEPENDS_append = " update-rc.d-native"

do_install_append() {
	install -d ${D}/${sysconfdir}/dbus-1/system.d
	install -d ${D}/${sysconfdir}/pulse

	install -m 0644 ${WORKDIR}/pulseaudio-bluetooth.conf ${D}/${sysconfdir}/dbus-1/system.d
	install -m 0644 ${WORKDIR}/system.pa ${D}/${sysconfdir}/pulse

	if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
		install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants
		install -m 0644 ${WORKDIR}/pulseaudio.service ${D}${sysconfdir}/systemd/system
		ln -sf ${sysconfdir}/systemd/system/pulseaudio.service \
                       ${D}${sysconfdir}/systemd/system/multi-user.target.wants/pulseaudio.service
	else
		install -d ${D}/${sysconfdir}/init.d
		install -m 0755 ${WORKDIR}/init ${D}/${sysconfdir}/init.d/pulseaudio
		update-rc.d -r ${D} pulseaudio defaults
	fi

	rm -f ${D}/${sysconfdir}/xdg/autostart/pulseaudio.desktop
}
