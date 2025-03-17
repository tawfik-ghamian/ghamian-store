// lib/modules/inventory/views/jewelry_list_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghamian_jewelry_app/modules/inventory/controllers/jewelry_list_controller.dart';
import 'package:ghamian_jewelry_app/routes/app_pages.dart';
import 'package:ghamian_jewelry_app/data/models/jewelry_model.dart';

class JewelryListView extends StatelessWidget {
  final controller = Get.put(JewelryListController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error loading inventory',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  controller.error.value,
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refreshJewelry,
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.jewelryItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No jewelry items found',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.toNamed(Routes.JEWELRY_ADD),
                  child: Text('Add New Item'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshJewelry(),
          child: ListView.builder(
            itemCount: controller.jewelryItems.length,
            itemBuilder: (context, index) {
              final item = controller.jewelryItems[index];
              return _buildJewelryCard(item);
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Get.toNamed(Routes.JEWELRY_ADD),
      ),
    );
  }

  Widget _buildJewelryCard(Jewelry jewelry) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: jewelry.imageUrl != null
              ? Image.network(
                  jewelry.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, _, __) => Icon(
                    Icons.diamond,
                    size: 32,
                    color: Colors.amber[700],
                  ),
                )
              : Icon(
                  Icons.diamond,
                  size: 32,
                  color: Colors.amber[700],
                ),
        ),
        title: Text(
          jewelry.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text('Category: ${jewelry.category}'),
            Text('Material: ${jewelry.material}'),
            SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text('\$${jewelry.price.toStringAsFixed(2)}'),
                  backgroundColor: Colors.amber[100],
                ),
                SizedBox(width: 8),
                Chip(
                  label: Text('${jewelry.quantity} in stock'),
                  backgroundColor:
                      jewelry.quantity > 0 ? Colors.green[100] : Colors.red[100],
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: () => Get.toNamed(
          Routes.JEWELRY_DETAIL.replaceAll(':id', jewelry.id),
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filter Inventory'),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  value: controller.selectedCategory.value.isEmpty
                      ? null
                      : controller.selectedCategory.value,
                  items: [
                    DropdownMenuItem<String>(
                      value: '',
                      child: Text('All Categories'),
                    ),
                    ...controller.categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    controller.selectedCategory.value = value ?? '';
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Material',
                    border: OutlineInputBorder(),
                  ),
                  value: controller.selectedMaterial.value.isEmpty
                      ? null
                      : controller.selectedMaterial.value,
                  items: [
                    DropdownMenuItem<String>(
                      value: '',
                      child: Text('All Materials'),
                    ),
                    ...controller.materials.map((material) {
                      return DropdownMenuItem<String>(
                        value: material,
                        child: Text(material),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    controller.selectedMaterial.value = value ?? '';
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Clear'),
              onPressed: () {
                controller.clearFilters();
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Apply'),
              onPressed: () {
                controller.applyFilters();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

// lib/modules/inventory/controllers/jewelry_list_controller.dart
import 'package:get/get.dart';
import 'package:ghamian_jewelry_app/data/providers/auth_provider.dart';
import 'package:ghamian_jewelry_app/data/providers/jewelry_provider.dart';
import 'package:ghamian_jewelry_app/core/constants/app_constants.dart';
import 'package:ghamian_jewelry_app/data/models/jewelry_model.dart';

class JewelryListController extends GetxController {
  final JewelryProvider _jewelryProvider = Get.put(JewelryProvider());
  final AuthProvider _authProvider = Get.find<AuthProvider>();

  final isLoading = false.obs;
  final error = RxString('');
  final jewelryItems = <Jewelry>[].obs;
  
  final selectedCategory = RxString('');
  final selectedMaterial = RxString('');
  
  List<String> get categories => AppConstants.jewelryCategories;
  List<String> get materials => AppConstants.materials;

  @override
  void onInit() {
    super.onInit();
    fetchJewelry();
  }

  Future<void> fetchJewelry() async {
    isLoading.value = true;
    error.value = '';

    try {
      // Only fetch jewelry for user's branch if they are a branch manager
      String? branchId;
      if (_authProvider.userRole == 'branch_manager') {
        branchId = _authProvider.userBranchId;
      }

      await _jewelryProvider.fetchJewelry(
        branchId: branchId,
        category: selectedCategory.value.isEmpty ? null : selectedCategory.value,
        material: selectedMaterial.value.isEmpty ? null : selectedMaterial.value,
      );
      
      jewelryItems.value = _jewelryProvider.jewelryItems;
    } catch (e) {
      error.value = 'Failed to load jewelry: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshJewelry() async {
    await fetchJewelry();
  }

  void clearFilters() {
    selectedCategory.value = '';
    selectedMaterial.value = '';
  }

  void applyFilters() {
    fetchJewelry();
  }
}

// lib/modules/inventory/views/jewelry_detail_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghamian_jewelry_app/modules/inventory/controllers/jewelry_detail_controller.dart';
import 'package:ghamian_jewelry_app/routes/app_pages.dart';

class JewelryDetailView extends StatelessWidget {
  final controller = Get.put(JewelryDetailController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.jewelry.value?.name ?? 'Jewelry Details')),
        actions: [
          Obx(() {
            if (controller.canEdit.value && controller.jewelry.value != null) {
              return IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => _showEditDialog(context),
              );
            }
            return SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error loading jewelry details',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  controller.error.value,
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.fetchJewelryDetails,
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.jewelry.value == null) {
          return Center(
            child: Text('Jewelry not found'),
          );
        }

        final jewelry = controller.jewelry.value!;

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Center(
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: jewelry.imageUrl != null
                      ? Image.network(
                          jewelry.imageUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (ctx, _, __) => Icon(
                            Icons.diamond,
                            size: 80,
                            color: Colors.amber[700],
                          ),
                        )
                      : Icon(
                          Icons.diamond,
                          size: 80,
                          color: Colors.amber[700],
                        ),
                ),
              ),
              SizedBox(height: 24),

              // Details
              Text(
                jewelry.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              _buildDetailRow('Category', jewelry.category),
              _buildDetailRow('Material', jewelry.material),
              _buildDetailRow('Weight', '${jewelry.weight} g'),
              _buildDetailRow('Price', '\$${jewelry.price.toStringAsFixed(2)}'),
              _buildDetailRow('Quantity', '${jewelry.quantity} in stock'),
              
              if (jewelry.description != null && jewelry.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(jewelry.description!),
                    ],
                  ),
                ),
              
              SizedBox(height: 24),
              
              // Branch info
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Branch Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildDetailRow(
                        'Branch',
                        jewelry.branch?.name ?? 'Unknown',
                      ),
                      _buildDetailRow(
                        'Location',
                        jewelry.branch?.location ?? 'Unknown',
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 24),
              
              // Action buttons
              if (controller.canTransfer.value)
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed(
                    Routes.TRANSFER_CREATE,
                    arguments: {'jewelryId': jewelry.id},
                  ),
                  icon: Icon(Icons.swap_horiz),
                  label: Text('Request Transfer'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final jewelry = controller.jewelry.value!;
    
    // Initialize form controllers with current values
    controller.nameController.text = jewelry.name;
    controller.categoryController.text = jewelry.category;
    controller.materialController.text = jewelry.material;
    controller.weightController.text = jewelry.weight.toString();
    controller.priceController.text = jewelry.price.toString();
    controller.quantityController.text = jewelry.quantity.toString();
    controller.descriptionController.text = jewelry.description ?? '';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Jewelry'),
          content: Container(
            width: double.maxFinite,
            child: Form(
              key: controller.formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: controller.nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: jewelry.category,
                      decoration: InputDecoration(labelText: 'Category'),
                      items: AppConstants.jewelryCategories
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ))
                          .toList(),
                      onChanged: (value) {
                        controller.categoryController.text = value ?? '';
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: jewelry.material,
                      decoration: InputDecoration(labelText: 'Material'),
                      items: AppConstants.materials
                          .map((material) => DropdownMenuItem(
                                value: material,
                                child: Text(material),
                              ))
                          .toList(),
                      onChanged: (value) {
                        controller.materialController.text = value ?? '';
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a material';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: controller.weightController,
                      decoration: InputDecoration(labelText: 'Weight (g)'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the weight';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: controller.priceController,
                      decoration: InputDecoration(labelText: 'Price (\$)'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: controller.quantityController,
                      decoration: InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the quantity';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: controller.descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                if (controller.formKey.currentState!.validate()) {
                  controller.updateJewelry();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}

// lib/modules/inventory/controllers/jewelry_detail_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghamian_jewelry_app/data/providers/jewelry_provider.dart';
import 'package:ghamian_jewelry_app/data/providers/auth_provider.dart';
import 'package:ghamian_jewelry_app/data/models/jewelry_model.dart';

class JewelryDetailController extends GetxController {
  final JewelryProvider _jewelryProvider = Get.find<JewelryProvider>();
  final AuthProvider _authProvider = Get.find<AuthProvider>();
  
  final isLoading = false.obs;
  final error = RxString('');
  final jewelry = Rxn<Jewelry>();
  
  final canEdit = false.obs;
  final canTransfer = false.obs;
  
  // Form controllers for editing
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final categoryController = TextEditingController();
  final materialController = TextEditingController();
  final weightController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();
  final descriptionController = TextEditingController();
  
  String get jewelryId => Get.parameters['id'] ?? '';
  
  @override
  void onInit() {
    super.onInit();
    fetchJewelryDetails();
  }
  
  @override
  void onClose() {
    nameController.dispose();
    categoryController.dispose();
    materialController.dispose();
    weightController.dispose();
    priceController.dispose();
    quantityController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
  
  Future<void> fetchJewelryDetails() async {
    if (jewelryId.isEmpty) {
      error.value = 'Invalid jewelry ID';
      return;
    }
    
    isLoading.value = true;
    error.value = '';
    
    try {
      final result = await _jewelryProvider.getJewelryById(jewelryId);
      
      if (result != null) {
        jewelry.value = result;
        
        // Set permissions
        final userRole = _authProvider.userRole;
        final userBranchId = _authProvider.userBranchId;
        
        // Admin can edit all jewelry
        canEdit.value = userRole == 'admin';
        
        // Branch manager can edit jewelry in their branch
        if (userRole == 'branch_manager' && userBranchId == result.branchId) {
          canEdit.value = true;
        }
        
        // Branch manager can request transfers from other branches
        canTransfer.value = userRole == 'branch_manager' && 
                          userBranchId != result.branchId &&
                          result.quantity > 0;
      } else {
        error.value = 'Jewelry not found';
      }
    } catch (e) {
      error.value = 'Error loading jewelry details: $e';
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> updateJewelry() async {
    if (jewelry.value == null) return;
    
    isLoading.value = true;
    error.value = '';
    
    try {
      final updatedJewelry = Jewelry(
        id: jewelry.value!.id,
        name: nameController.text,
        category: categoryController.text,
        material: materialController.text,
        weight: double.parse(weightController.text),
        price: double.parse(priceController.text),
        quantity: int.parse(quantityController.text),
        description: descriptionController.text,
        branchId: jewelry.value!.branchId,
        branch: jewelry.value!.branch,
        imageUrl: jewelry.value!.imageUrl,
      );
      
      final result = await _jewelryProvider.updateJewelry(
        jewelry.value!.id,
        updatedJewelry,
      );
      
      if (result) {
        Get.snackbar(
          'Success',
          'Jewelry updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        
        // Refresh the jewelry details
        await fetchJewelryDetails();
      } else {
        error.value = 'Failed to update jewelry';
        Get.snackbar(
          'Error',
          'Failed to update jewelry',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
        );
      }
    } catch (e) {
      error.value = 'Error updating jewelry: $e';
      Get.snackbar(
        'Error',
        'Error updating jewelry: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
      );
    } finally {
      isLoading.value = false;
    }
  }
}

// lib/modules/inventory/views/jewelry_add_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghamian_jewelry_app/modules/inventory/controllers/jewelry_add_controller.dart';
import 'package:ghamian_jewelry_app/core/constants/app_constants.dart';

class JewelryAddView extends StatelessWidget {
  final controller = Get.put(JewelryAddController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Jewelry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: controller.nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 