// 🛍️ Store Screen
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/store_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/product_model.dart';
import 'my_redemptions_screen.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({Key? key}) : super(key: key);

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoreProvider>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = context.watch<StoreProvider>();
    final authProvider = context.watch<AuthProvider>();
    final userPoints = authProvider.user?.client?.points ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tienda'),
        actions: [
          // Puntos del usuario
          Container(
            margin: EdgeInsets.only(right: AppTheme.spacing16),
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.spacing12,
              vertical: AppTheme.spacing8,
            ),
            decoration: BoxDecoration(
              gradient: AppTheme.orangeGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Row(
              children: [
                Icon(Icons.stars, color: Colors.white, size: 20),
                SizedBox(width: AppTheme.spacing4),
                Text(
                  '$userPoints',
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: storeProvider.isLoading && storeProvider.products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => storeProvider.refresh(),
              child: CustomScrollView(
                slivers: [
                  // Header con mis canjes
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppTheme.spacing16),
                      child: _buildMyRedemptionsCard(storeProvider),
                    ),
                  ),
                  
                  // Categorías
                  if (storeProvider.categories.length > 1)
                    SliverToBoxAdapter(
                      child: _buildCategoryFilter(storeProvider),
                    ),
                  
                  // Productos destacados
                  if (storeProvider.featuredProducts.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(AppTheme.spacing16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Destacados',
                              style: context.textTheme.headlineSmall,
                            ),
                            SizedBox(height: AppTheme.spacing12),
                          ],
                        ),
                      ),
                    ),
                  
                  if (storeProvider.featuredProducts.isNotEmpty)
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 220,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
                          itemCount: storeProvider.featuredProducts.length,
                          itemBuilder: (context, index) {
                            return _buildFeaturedProductCard(
                              storeProvider.featuredProducts[index],
                              storeProvider,
                              userPoints,
                            );
                          },
                        ),
                      ),
                    ),
                  
                  // Título de todos los productos
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppTheme.spacing16),
                      child: Text(
                        'Todos los Productos',
                        style: context.textTheme.headlineSmall,
                      ),
                    ),
                  ),
                  
                  // Grid de productos
                  storeProvider.filteredProducts.isEmpty
                      ? SliverFillRemaining(
                          child: _buildEmptyState(),
                        )
                      : SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return _buildProductCard(
                                  storeProvider.filteredProducts[index],
                                  storeProvider,
                                  userPoints,
                                );
                              },
                              childCount: storeProvider.filteredProducts.length,
                            ),
                          ),
                        ),
                  
                  SliverToBoxAdapter(
                    child: SizedBox(height: AppTheme.spacing32),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMyRedemptionsCard(StoreProvider provider) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryOrange.withOpacity(0.2),
            AppTheme.primaryOrange.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.primaryOrange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppTheme.spacing12),
            decoration: BoxDecoration(
              color: AppTheme.primaryOrange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Icon(
              Icons.redeem,
              color: AppTheme.primaryOrange,
              size: 28,
            ),
          ),
          SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mis Canjes',
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppTheme.spacing4),
                Text(
                  'Ver productos canjeados',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.textSecondCol,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MyRedemptionsScreen(),
                ),
              );
            },
            icon: Icon(Icons.arrow_forward_ios, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(StoreProvider provider) {
    return Container(
      height: 50,
      margin: EdgeInsets.only(bottom: AppTheme.spacing16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
        itemCount: provider.categories.length,
        itemBuilder: (context, index) {
          final category = provider.categories[index];
          final isSelected = provider.selectedCategory == category;
          
          return Container(
            margin: EdgeInsets.only(right: AppTheme.spacing8),
            child: FilterChip(
              label: Text(
                category == 'all' ? 'Todos' : category.toUpperCase(),
                style: TextStyle(
                  color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                provider.setCategory(category);
              },
              backgroundColor: context.cardColor,
              selectedColor: AppTheme.primaryOrange,
              checkmarkColor: Colors.white,
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedProductCard(ProductModel product, StoreProvider provider, int userPoints) {
    final canAfford = userPoints >= product.pointsPrice;
    
    return Container(
      width: 180,
      margin: EdgeInsets.only(right: AppTheme.spacing12),
      child: GestureDetector(
        onTap: () => _showProductDetail(product, provider, userPoints),
        child: Container(
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(color: AppTheme.primaryOrange.withOpacity(0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryOrange.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusLarge),
                  topRight: Radius.circular(AppTheme.radiusLarge),
                ),
                child: product.imageUrl != null
                    ? Image.network(
                        product.imageUrl!,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                      )
                    : _buildPlaceholderImage(),
              ),
              
              Padding(
                padding: EdgeInsets.all(AppTheme.spacing12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppTheme.spacing8),
                    Row(
                      children: [
                        Icon(Icons.stars, color: AppTheme.warningColor, size: 16),
                        SizedBox(width: AppTheme.spacing4),
                        Text(
                          '${product.pointsPrice}',
                          style: context.textTheme.bodyLarge?.copyWith(
                            color: canAfford ? AppTheme.warningColor : AppTheme.errorColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductModel product, StoreProvider provider, int userPoints) {
    final canAfford = userPoints >= product.pointsPrice;
    
    return GestureDetector(
      onTap: () => _showProductDetail(product, provider, userPoints),
      child: Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(color: context.borderCol),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusLarge),
                topRight: Radius.circular(AppTheme.radiusLarge),
              ),
              child: Stack(
                children: [
                  product.imageUrl != null
                      ? Image.network(
                          product.imageUrl!,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                        )
                      : _buildPlaceholderImage(),
                  
                  if (product.isOutOfStock)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.6),
                        child: Center(
                          child: Text(
                            'AGOTADO',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(AppTheme.spacing12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product.price > 0)
                          Text(
                            'Bs. ${product.price.toStringAsFixed(2)}',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.textSecondCol,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        Row(
                          children: [
                            Icon(Icons.stars, color: AppTheme.warningColor, size: 16),
                            SizedBox(width: AppTheme.spacing4),
                            Text(
                              '${product.pointsPrice}',
                              style: context.textTheme.bodyLarge?.copyWith(
                                color: canAfford ? AppTheme.warningColor : AppTheme.errorColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 120,
      color: context.surfaceColor,
      child: Center(
        child: Icon(
          Icons.shopping_bag,
          size: 48,
          color: context.textTertCol,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: context.textTertCol,
          ),
          SizedBox(height: AppTheme.spacing16),
          Text(
            'No hay productos disponibles',
            style: context.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  void _showProductDetail(ProductModel product, StoreProvider provider, int userPoints) {
    final canAfford = userPoints >= product.pointsPrice;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppTheme.radiusXLarge),
            topRight: Radius.circular(AppTheme.radiusXLarge),
          ),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacing24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen
                  if (product.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      child: Image.network(
                        product.imageUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                      ),
                    ),
                  
                  SizedBox(height: AppTheme.spacing20),
                  
                  // Nombre
                  Text(
                    product.name,
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  SizedBox(height: AppTheme.spacing8),
                  
                  // Categoría
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing8,
                      vertical: AppTheme.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Text(
                      product.category.toUpperCase(),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: AppTheme.spacing16),
                  
                  // Descripción
                  Text(
                    product.description,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.textSecondCol,
                    ),
                  ),
                  
                  SizedBox(height: AppTheme.spacing24),
                  
                  // Stock
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 20,
                        color: product.isOutOfStock ? AppTheme.errorColor : AppTheme.successColor,
                      ),
                      SizedBox(width: AppTheme.spacing8),
                      Text(
                        product.isOutOfStock ? 'Agotado' : '${product.stock} disponibles',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: product.isOutOfStock ? AppTheme.errorColor : AppTheme.successColor,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: AppTheme.spacing24),
                  
                  // Precio
                  Container(
                    padding: EdgeInsets.all(AppTheme.spacing16),
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(color: context.borderCol),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Canjear con puntos',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.textSecondCol,
                              ),
                            ),
                            SizedBox(height: AppTheme.spacing4),
                            Row(
                              children: [
                                Icon(Icons.stars, color: AppTheme.warningColor, size: 24),
                                SizedBox(width: AppTheme.spacing8),
                                Text(
                                  '${product.pointsPrice}',
                                  style: context.textTheme.headlineSmall?.copyWith(
                                    color: AppTheme.warningColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (!canAfford)
                          Text(
                            'Puntos insuficientes',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: AppTheme.errorColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: AppTheme.spacing24),
                  
                  // Botón de canje
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: product.isOutOfStock || !canAfford || provider.isLoading
                          ? null
                          : () => _handleRedeem(product, provider),
                      icon: Icon(Icons.redeem),
                      label: Text(
                        product.isOutOfStock
                            ? 'Agotado'
                            : !canAfford
                                ? 'Puntos insuficientes'
                                : 'Canjear ahora',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryOrange,
                        padding: EdgeInsets.symmetric(vertical: AppTheme.spacing16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRedeem(ProductModel product, StoreProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Canje'),
        content: Text(
          '¿Deseas canjear "${product.name}" por ${product.pointsPrice} puntos?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      Navigator.pop(context); // Cerrar bottom sheet
      
      final success = await provider.redeemProduct(product.id);
      
      if (success && mounted) {
        await context.read<AuthProvider>().refreshUser();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Producto canjeado! Recógelo en recepción'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Ver',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyRedemptionsScreen(),
                  ),
                );
              },
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Error al canjear producto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
