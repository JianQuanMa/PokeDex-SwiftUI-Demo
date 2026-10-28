import SwiftUI

struct PokemonDetailView: View {
    @State var viewModel: PokemonDetailViewModel

    var body: some View {
        content
            .navigationTitle(viewModel.summary.displayName)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: viewModel.toggleFavorite) {
                        Image(systemName: viewModel.isFavorite ? "star.fill" : "star")
                            .foregroundStyle(viewModel.isFavorite ? .yellow : .secondary)
                    }
                }
            }
            .task { await viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.viewState {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .error(let message):
            ContentUnavailableView {
                Label("Couldn't load details", systemImage: "wifi.slash")
            } description: {
                Text(message)
            } actions: {
                Button("Retry") { Task { await viewModel.load() } }
            }
        case .loaded(let detail):
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    artwork(for: detail)
                    typesRow(for: detail)
                    metrics(for: detail)
                    statsSection(for: detail)
                    abilitiesSection(for: detail)
                }
                .padding()
            }
        }
    }

    private func artwork(for detail: PokemonDetail) -> some View {
        AsyncImage(url: detail.artworkURL) { phase in
            if case .success(let image) = phase {
                image.resizable().scaledToFit()
            } else {
                ProgressView()
            }
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
    }

    private func typesRow(for detail: PokemonDetail) -> some View {
        HStack {
            ForEach(detail.types, id: \.self) { type in
                Text(type.capitalized)
                    .font(.caption).bold()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.2))
                    .clipShape(Capsule())
            }
        }
    }

    private func metrics(for detail: PokemonDetail) -> some View {
        HStack(spacing: 24) {
            VStack(alignment: .leading) {
                Text("Height").font(.caption).foregroundStyle(.secondary)
                Text("\(detail.heightInMeters, specifier: "%.1f") m")
            }
            VStack(alignment: .leading) {
                Text("Weight").font(.caption).foregroundStyle(.secondary)
                Text("\(detail.weightInKilograms, specifier: "%.1f") kg")
            }
        }
    }

    private func statsSection(for detail: PokemonDetail) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Base Stats").font(.headline)
            ForEach(detail.stats) { stat in
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(stat.displayName).font(.caption)
                        Spacer()
                        Text("\(stat.value)").font(.caption).foregroundStyle(.secondary)
                    }
                    ProgressView(value: stat.normalizedValue)
                }
            }
        }
    }

    private func abilitiesSection(for detail: PokemonDetail) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Abilities").font(.headline)
            Text(detail.abilities.map { $0.capitalized }.joined(separator: ", "))
                .foregroundStyle(.secondary)
        }
    }
}
