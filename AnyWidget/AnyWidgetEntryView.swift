
import WidgetKit
import SwiftUI

struct AnyWidgetEntryView: View {
    
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if entry.list.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Pinned devices not found")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("Please pin any device in the app.")
                        .foregroundStyle(.tertiary)
                        .font(.caption)
                    Text("*only first 3 pinned devices available.")
                        .foregroundStyle(.quaternary)
                        .font(.caption2)
                }
            } else {
                HStack {
                    Text("Devices")
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    Image(systemName: "star.fill")
                        .foregroundStyle(Color.custom.starColor)
                }
                .padding(.bottom, 2)
                Divider()
                ForEach(entry.list) { device in
                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(device.name)
                                .lineLimit(1)
                                .frame(width: .infinity)
                        }
                        Spacer(minLength: 4)
                        Button(intent: BootButtonIntent(id: device.id)) {
                            Image(systemName: "power")
                                .foregroundStyle(.primary)
                                .padding(4)
                                .background {
                                    Circle()
                                        .foregroundStyle(.blue.opacity(0.5))
                                }
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(maxWidth: .infinity)
                }
                Spacer()
            }
        }
        .containerBackground(.tertiary, for: .widget)
    }
}

struct Provider: TimelineProvider {
    
    @ObservedObject var widgetData = AnyWidgetData()
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(list: widgetData.deviceList)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        
        completion(SimpleEntry(list: widgetData.deviceList))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        var entries: [SimpleEntry] = []
        widgetData.fetchPinnedDevices()
        print("Updated in getTime")
        entries.append(SimpleEntry(list: widgetData.deviceList))
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date = .now
    let list: [Device]
}

struct AnyWidget: Widget {
    let kind: String = "MonitWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                AnyWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                AnyWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

