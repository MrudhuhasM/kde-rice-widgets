import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: "General"
        icon: "preferences-system"
        source: "configGeneral.qml"
    }
    ConfigCategory {
        name: "Clock"
        icon: "preferences-system-time"
        source: "configClock.qml"
    }
    ConfigCategory {
        name: "Music"
        icon: "audio-headphones"
        source: "configMusic.qml"
    }
    ConfigCategory {
        name: "System"
        icon: "utilities-system-monitor"
        source: "configSystem.qml"
    }
    ConfigCategory {
        name: "Appearance"
        icon: "preferences-desktop-color"
        source: "configAppearance.qml"
    }
}
