import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:zanmelodic/src/config/themes/styles.dart';
import 'package:zanmelodic/src/models/handle.dart';
import 'package:zanmelodic/src/models/result.dart';
import 'package:zanmelodic/src/modules/playlist/playlist/logic/playlist_bloc.dart';
import 'package:zanmelodic/src/modules/playlist/playlist_detail/logic/playlist_detail_bloc.dart';
import 'package:zanmelodic/src/modules/playlist/router/playlist_router.dart';
import 'package:zanmelodic/src/utils/utils.dart';
import 'package:zanmelodic/src/widgets/image_widget/custom_image_widget.dart';
import 'package:zanmelodic/src/widgets/state/state_empty_widget.dart';
import 'package:zanmelodic/src/widgets/state/state_error_widget.dart';
import 'package:zanmelodic/src/widgets/state/state_loading_widget.dart';

class PlaylistWidget extends StatelessWidget {
  const PlaylistWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaylistBloc, PlaylistState>(
      builder: (context, state) {
        XHandle<List<PlaylistModel>> _handle = state.items;
        if (_handle.isCompleted) {
          _handle = XHandle.result(XResult.success(state.items.data ?? []));
          final List<PlaylistModel> _items = _handle.data ?? [];
          state.isSortName ? state.sortListByNameReverse : state.sortListByName;
          state.isShuffle ? _items.shuffle() : null;
          return _items.isNotEmpty
              ? _buildGirdView(context, playlists: _items)
              : const XStateEmptyWidget();
        } else if (_handle.isLoading) {
          return const XStateLoadingWidget();
        } else {
          return const XStateErrorWidget();
        }
      },
    );
  }

  Widget _buildGirdView(BuildContext context,
      {required List<PlaylistModel> playlists}) {
    final _listLeft = [];
    final _listRight = [];
    for (var i = 0; i < playlists.length; i++) {
      i % 2 == 0 ? _listLeft.add(playlists[i]) : _listRight.add(playlists[i]);
    }
    return SliverToBoxAdapter(
        child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => _itemCard(context,
                playlist: _listLeft[index], width: 178, height: 162),
            itemCount: _listLeft.length,
          ),
        ),
        Expanded(
          flex: 5,
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemBuilder: (context, index) => _itemCard(context,
                playlist: _listRight[index], width: 182, height: 150),
            itemCount: _listRight.length,
          ),
        ),
      ],
    ));
  }

  Widget _itemCard(
    BuildContext context, {
    required PlaylistModel playlist,
    required double width,
    required double height,
  }) {
    return GestureDetector(
        onTap: () => context
            .read<PlaylistDetailBloc>()
            .fetchListOfSongsFromPlaylist(context, playlist: playlist),
        onLongPress: () => PlaylistCoordinator.showDialogRemovePlaylist(context,
            playlist: playlist),
        child: Padding(
            padding: const EdgeInsets.all(3.5),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomImageWidget(
                  id: playlist.id,
                  height: width,
                  width: height,
                  artworkType: ArtworkType.PLAYLIST,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(playlist.playlist,
                        style: Style.textTheme().titleMedium),
                    Text(XUtil.formatNumberSong(playlist.numOfSongs),
                        style: Style.textTheme().titleMedium),
                  ],
                ),
              ],
            )));
  }
}