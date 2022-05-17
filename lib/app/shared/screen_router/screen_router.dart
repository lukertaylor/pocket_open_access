import '../../features/article_detail/view/article_detail_screen.dart';
import '../../features/home_screen/view/home_screen.dart';
import '../../features/search/view/search_results.dart';
import '../../features/splash_screen/view/splash_screen.dart';
import '../../features/view_pdf/view/view_pdf_screen.dart';
import '../common_imports/common_imports_barrel.dart';
import '../widgets/undefined_route_screen.dart';

class ScreenRouter {
  Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (BuildContext context) => const SplashScreen(
            splashTestMode: false,
          ),
        );
      case '/home':
        return MaterialPageRoute(
          builder: (BuildContext context) => const HomeScreen(),
        );
      case '/search-results':
        return MaterialPageRoute(
          builder: (BuildContext context) => const SearchResults(),
        );
      case '/article-detail':
        final Article article = settings.arguments as Article;
        return MaterialPageRoute(
          builder: (BuildContext context) =>
              ArticleDetailScreen(article: article),
        );
      case '/view-pdf':
        final article = settings.arguments as Article;
        return MaterialPageRoute(
          builder: (BuildContext context) => PdfViewerCubitProvider(
            article: article,
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (BuildContext context) => const UndefinedRouteScreen(),
        );
    }
  }
}
