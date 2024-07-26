import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:uwin_flutter/src/blocs/delete_account_bloc.dart';
import 'package:uwin_flutter/src/blocs/providers/auth_block_provider.dart';
import 'package:uwin_flutter/src/widgets/app_button.dart';

class DeleteAccountScreen extends StatelessWidget {
  static const routeName = '/delete-account';

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            padding: EdgeInsetsDirectional.zero,
            border: null,
            largeTitle: Text('Delete Account'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'If you want to permanently delete your uWin account, please click of the delete button below.\n\nOnce the deletion process begins, you won\'t be able to undo it, you won\'t be able to log in to your account again, and all your data will be permanently deleted.',
                style: CupertinoTheme.of(context).textTheme.textStyle,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: AppButton(
                color: CupertinoColors.destructiveRed,
                child: Text('Delete my account'),
                onPressed: () async {
                  try {
                    await Provider.of<DeleteAccountBloc>(context, listen: false)
                        .deleteAccount();
                    final nav = Navigator.of(context);
                    if (nav.canPop()) {
                      nav.pop();
                    }
                    Provider.of<AuthBloc>(context, listen: false).logout();
                  } catch (err) {
                    showCupertinoDialog(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                        title: Text('Error'),
                        content: Text('$err'),
                        actions: [
                          CupertinoDialogAction(
                            child: Text('Okay'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: CupertinoButton(
                color: CupertinoColors.systemGrey,
                child: Text('Cancel'),
                onPressed: () {
                  final nav = Navigator.of(context);
                  if (nav.canPop()) {
                    nav.pop();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
