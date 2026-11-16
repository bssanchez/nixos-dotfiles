pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string apiKey: "fs_56izqmS6ozrJq38slQG3wI5W82ZBzjR6"
    readonly property string apiUrl: "https://www.festivos.com.co/api/v1/festivos"

    property var holidays: []
    property var _cache: ({})
    property bool loading: false
    property string error: ""
    property string _requestedKey: ""

    function monthKey(date) {
        return date.getFullYear() + "-" + String(date.getMonth() + 1).padStart(2, "0");
    }

    function fetchMonth(date, forceReload) {
        const key = monthKey(date);
        _requestedKey = key;

        if (!forceReload && _cache[key]) {
            holidays = _cache[key];
            error = "";
            loading = false;
            return;
        }

        holidays = [];
        error = "";
        loading = true;
        fetchProc.command = [
            "curl", "-fsS",
            "--header", "Authorization: Bearer " + apiKey,
            apiUrl + "?year=" + date.getFullYear() + "&month=" + (date.getMonth() + 1)
        ];
        fetchProc.running = true;
    }

    Process {
        id: fetchProc

        stdout: StdioCollector {
            onStreamFinished: {
                root.loading = false;
                const text = this.text.trim();
                if (text === "") {
                    root.error = "No fue posible obtener los festivos";
                    root.holidays = [];
                    return;
                }
                try {
                    const payload = JSON.parse(text);
                    const entries = (Array.isArray(payload.data) ? payload.data : []).map(e => ({
                        date: e.date,
                        name_es: e.name_es || "",
                        name_en: e.name_en || ""
                    }));
                    root._cache[root._requestedKey] = entries;
                    root.holidays = entries;
                    root.error = "";
                } catch (e) {
                    root.error = "Respuesta invalida del API de festivos";
                    root.holidays = [];
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                const text = this.text.trim();
                if (text !== "") {
                    root.loading = false;
                    root.error = text;
                    root.holidays = [];
                }
            }
        }
    }
}
